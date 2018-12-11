import psycopg2


def main():
    with psycopg2.connect(host="localhost",
                          database="datacube",
                          port=9999,
                          user='al6701') as conn:
        with conn.cursor() as cur:
            cur.execute("""
            select id from agdc.dataset_type
            where not metadata_type_ref = 2
            order by metadata_type_ref, name;
            """)
            id_result = cur.fetchall()

            for id in id_result:

                cur.execute(f"""
                select count(id) as count,
                       dataset_type_ref,
                       min((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as min_ul_lat,
                       max((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as max_ul_lat,
                       min((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as min_ur_lat,
                       max((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as max_ur_lat,
                       min((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision) as min_ll_lat,
                       max((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision) as max_ll_lat,
                       min((metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision) as min_lr_lat,
                       max((metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision) as max_lr_lat
                from agdc.dataset
                where dataset_type_ref = {id[0]}
                group by dataset_type_ref;
                """)

                print(cur.fetchone())


if __name__ == '__main__':
    main()
