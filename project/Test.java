// driver class 
public class Test  
{ 
    public static void main(String args[])  
    { 
        // using superclass reference 
        // first approach 
        Bicycle mb2 = new MountainBike(4, 200, 20); 
          
        // using subclass reference( ) 
        // second approach 
        MountainBike mb1 = new MountainBike(3, 100, 25); 
        mb1.setHeight("potato");
          
        System.out.println("seat height of first bicycle is " 
                                            + mb1.seatHeight); 
              
        // In case of overridden methods 
        // always subclass  
        // method will be executed 
        System.out.println(mb1.toString()); 
        System.out.println(mb2.toString()); 
  
        /* The following statement is invalid because Bicycle 
        does not define a seatHeight.  
        // System.out.println("seat height of second bicycle is "  
                                                + mb2.seatHeight); */
                      
        /* The following statement is invalid because Bicycle 
        does not define setHeight() method.  
        mb2.setHeight(21);*/
  
    } 
} 