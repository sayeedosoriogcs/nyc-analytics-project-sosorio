# NYC Analytics — dbt Project (CIS 9440 Group X)

## Milestone 4 Files
All project work is under `models/milestone_work/`.

| File | Description |
|------|-------------|
| `dbt_project.yml` | Project config and materialization settings |
| `models/milestone_work/staging/stg_nyc_311_sr.sql` | Staging for 311 data |
| `models/milestone_work/staging/stg_motorvehicle_collisions_crashes.sql` | Staging for collisions |
| `models/milestone_work/marts/shared/dim_date_m3.sql` | Shared date dimension |
| `models/milestone_work/marts/shared/dim_location_m3.sql` | Shared location dimension |
| `models/milestone_work/marts/nyc_311/dim_complaint_type_m3.sql` | Complaint type dimension |
| `models/milestone_work/marts/nyc_311/dim_agency.sql` | Agency dimension |
| `models/milestone_work/marts/nyc_311/fact_illegal_parking_complaint.sql` | 311 fact table |
| `models/milestone_work/marts/motor_vehicle_collisions/dim_contributing_factor.sql` | Contributing factor dimension |
| `models/milestone_work/marts/motor_vehicle_collisions/dim_vehicle.sql` | Vehicle dimension |
| `models/milestone_work/marts/motor_vehicle_collisions/fact_motor_vehicle_collision.sql` | Collision fact table |

## Notes
- Homework files may also exist — project work is scoped to `models/milestone_work/` only
- BigQuery project: `cis-9440-sayeedosorio`
- Run `dbt deps` before `dbt run` (requires dbt-utils)