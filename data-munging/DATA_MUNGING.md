# data-munging
This directory contains scripts used to process data from https://data.seattle.gov so it can be added to the OpenOversight database.

---

## *divest_spd_links.py*
This is a script for taking 1) the officer list from OpenOversight and 2) the list of Divest SPD threads and combining them into a links CSV that can be used with the [advanced CSV importer](https://openoversight.readthedocs.io/en/latest/advanced_csv_import.html#links-csv).
If you'd like to test this locally reach out to me, I'll provide you the Divest SPD CSV.

### **Usage**
1. `python data-munging/divest_spd_links.py <OO-CSV> <Divest-SPD-CSV> <output>`
2. `just import "Seattle\ Police\ Department" --links-csv /data/munged-divest-links.csv` 

### **Screenshot**
<img src="https://user-images.githubusercontent.com/10214785/129465909-b0a6bec2-35ad-4d3f-88c9-b5de51517c59.png" alt="Officer Detail" width="400" height="400">

---

## *demographic_data.py*

This is a script for taking the officer list from OpenOversight and the demographic data available from the [Seattle City Crisis Dataset](https://data.seattle.gov/Public-Safety/Crisis-Data/i2q9-thny). This one is very similar to [divest_spd_links.py](https://github.com/OrcaCollective/OpenOversight/blob/main/data-munging/divest_spd_links.py), and if this trend continues I might generalize some of the machinery that combines the data with the OO records.

### **Usage**
1. Download the [Crisis Data CSV](https://data.seattle.gov/Public-Safety/Crisis-Data/i2q9-thny).
2. `python data-munging/demographic_data.py <OO-CSV> <Crisis-Data-CSV> <output>`
3. `just import --officers-csv /data/demographic-data.csv "Seattle\ Police\ Department"`

### **Screenshot**
<img src="https://user-images.githubusercontent.com/10214785/130710081-9d8427ab-3551-4e16-849b-6a4f31cf7a1b.png" alt="Officer Detail" width="400" height="200">

---

## *spd_2020_salary_data.py*
This is a script for taking the officer list from OpenOversight and the salary data we were able to pull from the News Tribune. This one is very similar to [demographic_data.py](https://github.com/OrcaCollective/OpenOversight/blob/main/data-munging/demographic_data.py). 

### **Usage**
1. Contact me for the 2020 salary data.
2. `python data-munging/spd_2020_salary_data.py <OO-CSV> <Salary-CSV> <output>`
2. `just import --salaries-csv /data/salary-data.csv "Seattle\ Police\ Department"`

### **Screenshot**
<img src="https://user-images.githubusercontent.com/10214785/132084045-411fd1ad-8b8c-475a-973a-fc526563b9fc.png" alt="Officer Detail" width="400" height="300">

---

## *assignments.py*
This is a script for taking the officer list from OpenOversight and the historical roster data and generating two artifacts: 1) a sheet of officers that were active at any point after 2020 that may have left the force and 2) a list of assignments per officer. This one has a number of complexities with it due to how I'm reducing the historical data to create the assignments. I'm hoping I've added enough comments, let me know if I can elaborate.

The data we had is Very Bad (thanks SPD) so I spent some time working through the title and descriptions to generate the correction mappings that are found in [assignment_correction](https://github.com/OrcaCollective/OpenOversight/tree/main/data-munging/assignment_correction).

### **Usage**
The historical roster data is borrowed from [SPD Lookup](https://github.com/OrcaCollective/spd-lookup/blob/main/seed/Seattle-WA-Police-Department_Historical.csv). Note that there are some badges (e.g. `#4202` I think) that need to be cleaned up in that source data, since they look like timestamps.

**NOTE:** Before the assignments are uploaded, the current jobs & assignment tables (yes, in prod too) should be truncated.

1. `python data-munging/assignments.py <openoversight-officers-csv> <spd-historical-data> data/spd_assignments_updated.csv`
2. (Using `just db-shell`) `TRUNCATE jobs, assignments RESTART IDENTITY;`
3. `just import --assignments-csv /data/spd_assignments_updated.csv "Seattle\ Police\ Department"`
4. (Using `just db-shell`) `DELETE FROM unit_types WHERE id IN ( SELECT u.id FROM unit_types u LEFT JOIN assignments a ON u.id = a.unit_id WHERE a.id IS NULL);`


### **Screenshot**
<img src="https://user-images.githubusercontent.com/10214785/137671988-ca16ad92-0b76-440c-86ac-dda107ef90c3.png" alt="Officer Detail" width="400" height="200">

---

## *first_employed_date.py*
Super quick/small script to generate the "first employed date" field on officers, based on the assignments.csv sheet which can be downloaded from OO.

This is dependent on running the upload for [assignments.py](https://github.com/OrcaCollective/OpenOversight/blob/main/data-munging/assignments.py).

### **Usage**
1. Use OpenOversight to download the assignments CSV.
2. `python data-munging/first_employed_date.py <Assignment-CSV> <output>`
1. `just import --officers-csv /data/first_employed_date.csv "Seattle\ Police\ Department"`

### **Screenshot**
<img src="https://user-images.githubusercontent.com/10214785/132561937-a24da3cd-ad12-42e1-97c0-1cfdd8b8d785.png" alt="Officer Detail" width="300" height="200">

---

## *spd_2021_salary_data.py*
Script for adding 2021 salary data to OO using the [wage data](https://data.seattle.gov/City-Business/City-of-Seattle-Wage-Data/2khk-5ukd) that's available publicly for Seattle. It's based primarily on [spd_2020_salary_data.py](https://github.com/OrcaCollective/OpenOversight/blob/main/data-munging/spd_2020_salary_data.py).

### **Usage**
1. 2021 hourly rates are downloaded automatically from [here](https://data.seattle.gov/City-Business/City-of-Seattle-Wage-Data/2khk-5ukd).
2. `python data-munging/spd_2021_salary_data.py <OO-CSV> <output>`
3. `just import --salaries-csv /data/spd-2021-salary-data.csv "Seattle\ Police\ Department"`

### **Screenshot**
<img src="https://user-images.githubusercontent.com/10214785/138535974-23bdc285-12d2-4a5e-8868-ab5f592aa5a5.png" alt="Officer Detail" width="300" height="100">