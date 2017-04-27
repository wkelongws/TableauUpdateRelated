import com.jcraft.jsch.*;
import java.io.*;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.math3.analysis.interpolation.LinearInterpolator;
import org.apache.commons.math3.analysis.polynomials.PolynomialSplineFunction;
import org.apache.commons.math3.stat.descriptive.rank.Percentile;
import org.joda.time.LocalDate;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

import java.lang.Object;

public class test
{
public static void main(String[] args) throws Exception 
{
	double[] speed_ini_Dir1 = {67.0,68.0,69.0,0.0,71.0,72.0,73.0,0.0,74.0};
	double[] mm_ini_Dir1 = {1,2,3,4,5,6,7,8,9};
	double[] MM_PROJ_Dir1 = {1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5};
	double[] speed_proj_Dir1 = speed_ini_Dir1;
	
//	int flag0=0;
//	int flag1=0;
//	
//	while (flag1==0)
//	{
//		
//	}
//	
//	double[] array=speed_ini_Dir1;
//	List<Double> list = new ArrayList<Double>(Arrays.asList(ArrayUtils.toObject(array)));
//	list.removeAll(Arrays.asList(0.0));
//	
//	System.out.println(list);
	
	List<Double> y = new ArrayList<Double>(Arrays.asList(ArrayUtils.toObject(speed_ini_Dir1)));
	List<Double> x = new ArrayList<Double>(Arrays.asList(ArrayUtils.toObject(mm_ini_Dir1)));

	
	while(y.indexOf(0.0)>-1)
	{
		int index = y.indexOf(0.0);
		y.remove(index);
		x.remove(index);
	}
	
	double[] X = new double[x.size()];
	double[] Y = new double[y.size()];
	for (int i=0;i<X.length;i++)
	{
		X[i]=x.get(i);
		Y[i]=y.get(i);
	}
	
	speed_proj_Dir1 = linearInterp(X, Y, MM_PROJ_Dir1);
//	speed_proj_Dir1 = linearInterp(mm_ini_Dir1, speed_ini_Dir1, MM_PROJ_Dir1);
	
	System.out.println(Arrays.asList(ArrayUtils.toObject(speed_proj_Dir1)));
	
	
//	double[] x = { 0, 50, 100 };
//    double[] y = { 0, 50, 200 };
//
//    LinearInterpolator interp = new LinearInterpolator();
//    PolynomialSplineFunction f = interp.interpolate(x, y);
//
//    System.out.println("Piecewise functions:");
//    Arrays.stream(f.getPolynomials()).forEach(System.out::println);
//
//    double value = f.value(70);
//    System.out.println("y for xi = 70: " + value);
}


//linear interpolation function	
	public static double[] linearInterp(double[] x, double[] y, double[] xi) {
	   LinearInterpolator li = new LinearInterpolator(); // or other interpolator
	   PolynomialSplineFunction psf = li.interpolate(x, y);

	   double[] yi = new double[xi.length];
	   for (int i = 0; i < xi.length; i++) {
	       yi[i] = psf.value(xi[i]);
	   }
	   return yi;
	}

}