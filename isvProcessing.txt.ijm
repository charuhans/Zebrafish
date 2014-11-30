// dir1 is the path to isv data set folder
dir1 = getDirectory("C:\\Users\\joseph\\Desktop\\dr shah\\isvData");
// dir2 is the path to segmented isv folder
dir2 = getDirectory("C:\\Users\\joseph\\Desktop\\dr shah\\isvBW");
// dir3 is the path to skeleton isv folder
//dir3 = getDirectory("C:\\Users\\joseph\\Desktop\\dr shah\\isvSkeleton");

if (File.exists(dir1)) 
{ 
	list = getFileList(dir1);
	 
	for (i=0; i<list.length; i++) 
	{
		if (endsWith(list[i], ".tif")) 
		{
			open(dir1 + list[i]);
			run("Enhance Contrast", "saturated=0.35");
			run("Enhance Contrast", "saturated=0.35");
			run("Enhance Contrast", "saturated=0.35");
			run("Enhance Contrast", "saturated=0.35");
			run("Enhance Contrast", "saturated=0.35");
			
			run("Exact Euclidean Distance Transform (3D)");
			
			getStatistics(mean, min, max, std, histogram); 
			run("Frangi Vesselness (imglib, experimental)", "number=20 minimum=1 maximum=max");
			setAutoThreshold("RenyiEntropy dark");
			run("Convert to Mask");
			run("Analyze Particles...", "size=100-Infinity circularity=0.00-1.00 show=Masks");
			saveAs("TIFF", dir2+list[i]);
			close();
			close();
			close();

	  }
	}
}

else 
    showMessage('The directory '+dir1+' was not found.'); 
