import glob
import os
import subprocess
# for i in range(0,145):
#     files = glob.glob(f"/home/chenfushi/biomodal-structural-bioinformatics/vertex_runs/ntDRM2_output/ntDRM2_combination_screen_{i}/predictions/*")
#     if len(files) < 20:
#         print(f"Position {i} misses predictions.")
#         subprocess.run(f"python launch_vertex_job.py --folder_id ntDRM2_combination_screen_{i} --region us-east4", shell=True)

# for i in range(0,358):
#     files = glob.glob(f"/home/chenfushi/biomodal-structural-bioinformatics/vertex_runs/ntDRM2_output/ntDRM2_screen_N209K_background_{i}/predictions/*")
#     if len(files) < 20:
#         print(f"Position {i} misses predictions.")
#         if i < 100:
#             subprocess.run(f"python launch_vertex_job.py --folder_id ntDRM2_screen_N209K_background_{i} --region us-west1 ", shell=True)
#         elif i < 200:
#             subprocess.run(f"python launch_vertex_job.py --folder_id ntDRM2_screen_N209K_background_{i} --region us-west1 ", shell=True)
#         else:
#             subprocess.run(f"python launch_vertex_job.py --folder_id ntDRM2_screen_N209K_background_{i} --region us-west1 ", shell=True)


# for i in [43, 44, 205, 206, 207, 208, 209, 210, 211, 237, 238, 239, 240, 241, 242, 261, 262, 266, 287, 288, 289, 290, 313, 314, 317, 337]:
#     files = glob.glob(f"/home/chenfushi/biomodal-structural-bioinformatics/vertex_runs/ntDRM2_output/ntDRM2_with_SAH_{i}/predictions/*")
#     if len(files) < 20:
#         print(f"Position {i} misses predictions.")
#         subprocess.run(f"python launch_vertex_job.py --folder_id ntDRM2_with_SAH_{i} --region us-west1 ", shell=True)

for i in range(61,106):
    files = glob.glob(f"/home/chenfushi/biomodal-structural-bioinformatics/vertex_runs/walraj_analogs_output/processing_group_{i}/predictions/*")
    if len(files) < 10:
        subprocess.run(f"python launch_vertex_job.py --parent_folder walraj_analogs --folder_id processing_group_{i} --region us-west1 --operation affinity", shell=True)
        print(i)
