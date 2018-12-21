import psycopg2
import time


def main():
    output_filename = "extent_output2.txt"

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

            for dataset_id in id_result:
                with open(output_filename, "a") as f:
                    f.write(f"dataset_type: {dataset_id[0]}\n")

                start = time.time()

                cur.execute(f"""
                select (metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision as ul_lats,
                       (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision as ur_lats,
                       (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision as ll_lats,
                       (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision as lr_lats
                from agdc.dataset
                where archived IS NULL and dataset_type_ref = {dataset_id[0]};
                """)
                query_done = time.time()

                product_values = cur.fetchall()
                ul_lats = []
                ur_lats = []
                ll_lats = []
                lr_lats = []
                for product_value in product_values:
                    ul_lats.append(product_value[0])
                    ur_lats.append(product_value[1])
                    ll_lats.append(product_value[2])
                    lr_lats.append(product_value[3])

                ul_lat_min = 0
                ul_lat_max = 0
                ur_lat_min = 0
                ur_lat_max = 0
                ll_lat_min = 0
                ll_lat_max = 0
                lr_lat_min = 0
                lr_lat_max = 0
                if ul_lats:
                    ul_lat_min = min(ul_lats)
                    ul_lat_max = max(ul_lats)
                if ur_lats:
                    ur_lat_min = min(ur_lats)
                    ur_lat_max = max(ur_lats)
                if ll_lats:
                    ll_lat_min = min(ll_lats)
                    ll_lat_max = max(ll_lats)
                if lr_lats:
                    lr_lat_min = min(lr_lats)
                    lr_lat_max = max(lr_lats)

                end = time.time()

                with open(output_filename, "a") as f:
                    if ul_lats:
                        size = len(ul_lats)
                    else:
                        size = 0
                    f.write(f"size: {size}\n")
                    f.write(f"total_time: {end - start}\n")
                    f.write(f"query_time: {query_done - start}\n")
                    f.write(f"sort_time: {end - query_done}\n")

                    f.write(f"ul_lat_min:{ul_lat_min}\n")
                    f.write(f"ul_lat_max:{ul_lat_max}\n")
                    f.write(f"ur_lat_min:{ur_lat_min}\n")
                    f.write(f"ur_lat_max:{ur_lat_max}\n")
                    f.write(f"ll_lat_min:{ll_lat_min}\n")
                    f.write(f"ll_lat_max:{ll_lat_max}\n")
                    f.write(f"lr_lat_min:{lr_lat_min}\n")
                    f.write(f"lr_lat_max:{lr_lat_max}\n\n\n")


if __name__ == '__main__':
    main()
