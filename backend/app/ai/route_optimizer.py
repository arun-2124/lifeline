from ortools.constraint_solver import routing_enums_pb2
from ortools.constraint_solver import pywrapcp
from app.models.route_model import RouteOptimizationRequest, RouteOptimizationResponse, OptimizedStep
from app.services.maps_service import MapsService

class RouteOptimizer:
    @staticmethod
    def optimize(request: RouteOptimizationRequest) -> RouteOptimizationResponse:
        all_nodes = [request.start_location] + request.waypoints
        num_locations = len(all_nodes)

        if num_locations <= 1:
            return RouteOptimizationResponse(
                volunteer_id=request.volunteer_id,
                optimized_sequence=[],
                total_distance_km=0.0,
                total_estimated_mins=0
            )

        # Distance Matrix Construction (in meters for integer precision)
        matrix = []
        for i in range(num_locations):
            row = []
            for j in range(num_locations):
                d_km = MapsService.haversine_distance(
                    all_nodes[i].latitude, all_nodes[i].longitude,
                    all_nodes[j].latitude, all_nodes[j].longitude
                )
                row.append(int(d_km * 1000.0))
            matrix.append(row)

        # Create OR-Tools Routing Model
        manager = pywrapcp.RoutingIndexManager(num_locations, 1, 0)
        routing = pywrapcp.RoutingModel(manager)

        def distance_callback(from_index, to_index):
            from_node = manager.IndexToNode(from_index)
            to_node = manager.IndexToNode(to_index)
            return matrix[from_node][to_node]

        transit_callback_index = routing.RegisterTransitCallback(distance_callback)
        routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)

        search_parameters = pywrapcp.DefaultRoutingSearchParameters()
        search_parameters.first_solution_strategy = (
            routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC
        )

        solution = routing.SolveWithParameters(search_parameters)

        optimized_steps = []
        total_dist_m = 0

        if solution:
            index = routing.Start(0)
            step_idx = 1

            while not routing.IsEnd(index):
                node = manager.IndexToNode(index)
                next_index = solution.Value(routing.NextVar(index))
                next_node = manager.IndexToNode(next_index)

                leg_dist_km = round(matrix[node][next_node] / 1000.0, 2) if not routing.IsEnd(next_index) else 0.0
                total_dist_m += matrix[node][next_node] if not routing.IsEnd(next_index) else 0

                curr = all_nodes[node]
                optimized_steps.append(OptimizedStep(
                    step_number=step_idx,
                    waypoint_id=curr.id,
                    name=curr.name,
                    type=curr.type,
                    distance_from_prev_km=leg_dist_km,
                    estimated_travel_mins=int(leg_dist_km * 3.0 + 3)
                ))
                index = next_index
                step_idx += 1

        total_km = round(total_dist_m / 1000.0, 2)
        total_mins = int(total_km * 3.0 + (len(optimized_steps) * 5))

        return RouteOptimizationResponse(
            volunteer_id=request.volunteer_id,
            optimized_sequence=optimized_steps,
            total_distance_km=total_km,
            total_estimated_mins=total_mins
        )
