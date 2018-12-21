import psycopg2
import time


def main():
    output_filename = "corners_compared.txt"

    with psycopg2.connect(host="localhost",
                          database="postgres",
                          port=5439,
                          user='postgres') as conn:
        with conn.cursor() as cur:
            cur.execute("""
            select dataset_type_ref,
              (metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision as ul_lat,
              (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision as ur_lat,
              (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision as ll_lat,
              (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision as lr_lat,
              (metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision as ul_lon,
              (metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision as ur_lon,
              (metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision as ll_lon,
              (metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision as lr_lon
            from agdc.dataset
            where (archived is null)
            limit 5
            ;
            """)
            entry_coordinates = cur.fetchall()

            for entry_coordinate in entry_coordinates:
                dataset_type_ref, ul_lat, ur_lat, ll_lat, lr_lat, ul_lon, ur_lon, ll_lon, lr_lon = entry_coordinate
                
                compared = [ul_lat < ur_lat, ur_lat < lr_lat, lr_lat < ll_lat, ll_lat < ul_lat,
                            ul_lon < ur_lon, ur_lon < lr_lon, lr_lon < ll_lon, ll_lon < ul_lon]
                
                with open(output_filename, "a") as f:
                    f.write(','.join(str(x) for x in compared) + "\n")


if __name__ == '__main__':
    main()
