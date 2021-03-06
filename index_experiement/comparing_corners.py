import psycopg2


def main():
    output_filename = "corners_compared%d.txt"

    with psycopg2.connect(host="localhost",
                          database="postgres",
                          port=5439,
                          user='postgres') as conn:
        with conn.cursor() as cur:
            limit = 100000
            offset = 0
            i = 0
            while i == offset:
                cur.execute(f"""
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
                limit {limit} offset {offset}
                ;
                """)
                offset += limit
                entry_coordinates = cur.fetchall()

                with open(output_filename % offset, "w") as f:
                    for entry_coordinate in entry_coordinates:
                        dataset_type_ref, ul_lat, ur_lat, ll_lat, lr_lat, ul_lon, ur_lon, ll_lon, lr_lon = entry_coordinate

                        if dataset_type_ref and \
                                ul_lat and ur_lat and ll_lat and lr_lat and \
                                ul_lon and ur_lon and ll_lon and lr_lon:
                            compared = [int(ul_lat > ll_lat), int(ur_lat > lr_lat), int(ul_lon < ur_lon), int(ll_lon < lr_lon)]
                            f.write(f"i:{i}," + ','.join(str(x) for x in compared) + "\n")

                        i += 1


if __name__ == '__main__':
    main()
