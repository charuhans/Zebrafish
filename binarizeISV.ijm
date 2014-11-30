// dir1 is the path to data set folder
dir1 = getDirectory("C:\\Users\\charu\\Desktop\\Research\\isvBW");
// dir2 is the path to segmented image folder
dir2 = getDirectory("C:\\Users\\charu\\Desktop\\Research\\isvSkeleton");
//f = File.open("C:/Users/charu/Desktop/ResearchZebrafishVascular/name.txt");

if (File.exists(dir1))
 { 
	list = getFileList(dir1);
 
	for (i=0; i<list.length; i++)
	{
	  	if (endsWith(list[i], ".tif")) 
	  	{
	  		open(dir1 + list[i]);
	  		name = getTitle();
	  		
	  		//print(f,name);
	  		//run("Invert");
			//run("Skeletonize (2D/3D)");
			//////run("Analyze Particles...", "size=5-Infinity circularity=0.00-1.00 show=Masks");
			run("Analyze Skel", "prune=none calculate");
			//////run("Invert");
			saveAs("TIFF", dir2+list[i]);
			//////run("Analyze Skel", "prune=[shortest branch] calculate");
			
			close();
			close();
			close();
			//close();
	  	}
	}
 }


