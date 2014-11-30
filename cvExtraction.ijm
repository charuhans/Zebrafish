
// dir1 is the path to data set folder
dir1 = getDirectory("C:\\Users\\joseph\\Desktop\\dr shah\\isolateData");
// dir2 is the path to segmented image folder
dir2 = getDirectory("C:\\Users\\joseph\\Desktop\\dr shah\\data\\initialSegBW");
dir4 = getDirectory("C:\\Users\\joseph\\Desktop\\dr shah\\data\\skeleton");
if (File.exists(dir1))
 { 
	list = getFileList(dir1);
 
	for (i=0; i<list.length; i++)
	{
	  	if (endsWith(list[i], ".tif")) 
		{
	    		open(dir1 + list[i]);
			run("Enhance Contrast...", "saturated=10 normalize");
			saveAs("TIFF", dir1+list[i]);
			close();

			open(dir1 + list[i]);		
			run("Gaussian Blur...", "sigma=6");	
			setAutoThreshold("Intermodes");
			////setAutoThreshold("Intermodes dark");
			//getThreshold(threshold, min); 
	        		//print(threshold); 
			//threshold =threshold ;	  
			//setThreshold(0, threshold);
			setOption("BlackBackground", false);
			run("Convert to Mask");
			
			run("Invert");
			run("Analyze Particles...", "size=150-Infinity circularity=0.00-1.00 show=Masks");
			run("Fill Holes");
			run("Invert");
			saveAs("TIFF", dir2+list[i]);
			close();
			
			open(dir2 + list[i]);
			run("Invert");
			run("Smooth");
			run("Skeletonize (2D/3D)");
			saveAs("TIFF", dir4+list[i]);
			close();
			close();
			//close();
			
			
		}
	}
 }