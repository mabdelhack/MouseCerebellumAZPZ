# MouseCerebellumAZPZ

## Description
This is a code repository for codes used in [Regional differences in Purkinje cell morphology in the cerebellar vermis of male mice.
](https://doi.org/10.1002/jnr.24206). The code computes the following:

- Mean binary overlap area between each two cell pairs
- Spatial occupancy by dividing the hull by the convex hull
- Heatmap of overall overlap of the whole dendritic forest

## Dependencies
The code uses many tools from the [TREES 1.15 toolbox](http://www.treestoolbox.org/) so it depends on its existence in the path

The data is also available at [Neuromorpho](http://neuromorpho.org/NeuroMorpho_Linkout.jsp?PMID=29319237) where we the code uses the swc format to load the data.

We also used the library [Polygon Clipper](https://www.mathworks.com/matlabcentral/fileexchange/8818-polygon-clipper). It is reuploaded here for convenience.

We also depend in the [geom2D toolbox](https://www.mathworks.com/matlabcentral/fileexchange/7844-geom2d). Part of it is added here for convenience.

## Usage
First, data should be downloaded into the data folder, with 2 subfolders for AZ and PZ
Each of the subfolders is to have a folder for each forest, the folder should start with the mice ages "young" vs "old".

The running the script store_swc_into_mtr.m will convert the swc files into TREES mtr format. From that point we can run different analyses

### Binary overlap
TBA

### Hull vs convex hull
Run the hull_chull.m script

### Overlap heatmap
Run the roihull.m script



