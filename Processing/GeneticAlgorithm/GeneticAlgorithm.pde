/* by Ira Winder [jiw@mit.edu] as a demonstrative learning aid 
 * for Mingrui Wang [9860851159@edu.k.u-tokyo.ac.jp]
 * For educational purposes ONLY!
 */

/* The following script will implement the following:
 * 1. Parameterized model of a logistics network,  according to Mingrui's work
 * 2. Evaluation of the network's cost
 * 3. Genetic Algorithm to discover least cost solution
 */
 
/* Model Description:
 * 
 * The model assumes that 20 given sites create a net amount of refuse 
 * that needs to be collected and delivered to a set of "Stations" over a period of time.
 * The model may implement the construction of up to 10 stations
 * that have pre-known locations,  construction costs,  and transportation costs
 * associated with them. 
 */

/* Optimization Goal: 
*
 * Since each potential station will have unique capital cost
 * and operations costs,  it is not obvious which configuration will be the cheapest to build.
 * Therefore,  we build our model to discover solution that achieves the minimum cost while
 * providing enough capacity for all refuse to be collected.
 */
 
/* Site-to-Station Transportation Costs: 
 * For each site, the following matrix describes 
 * the total cost of delivering 1 unit of "request" to one of 10 stations
 *
 * Example Row: 
 *   Site  N    {Station 1 Cost, Station 2 Cost, ... , Station 10 Cost}
 *
 */
float[][] TRANSPORT_COST_PER_REQUEST = {
  /* Site  1 */ {6.1, 1.1, 10.1, 4.1, 5.1, 8.1, 7.1, 3.1, 2.1, 9.1}, 
  /* Site  2 */ {4.2, 9.2, 6.2, 10.2, 5.2, 7.2, 3.2, 8.2, 2.2, 8.2}, 
  /* Site  3 */ {10.3, 9.3, 6.3, 4.3, 1.3, 8.3, 7.3, 3.3, 2.3, 5.3}, 
  /* Site  4 */ {2.4, 9.4, 1.4, 7.4, 5.4, 3.4, 4.4, 8.4, 10.4, 6.4}, 
  /* Site  5 */ {4.5, 5.5, 6.5, 10.5, 9.5, 1.5, 7.5, 8.5, 2.5, 3.5}, 
  /* Site  6 */ {10.6, 1.6, 6.6, 4.6, 8.6, 3.6, 7.6, 5.6, 2.6, 9.6}, 
  /* Site  7 */ {10.7, 3.7, 6.7, 4.7, 5.7, 9.7, 1.7, 8.7, 2.7, 7.7}, 
  /* Site  8 */ {10.8, 9.8, 6.8, 4.8, 5.8, 1.8, 7.8, 1.8, 2.8, 8.8}, 
  /* Site  9 */ {10.9, 9.9, 6.9, 4.9, 5.9, 3.9, 2.9, 8.9, 7.9, 3.9}, 
  /* Site 10 */ {10.4, 3.2, 6.4, 4.3, 1.3, 8.8, 6.9, 8.4, 1.9, 5.4},
  /* Site 11 */ {2.1, 9.1, 4.1, 6.1, 5.1, 3.1, 7.1, 1.1, 10.1, 8.2}, 
  /* Site 12 */ {10.2, 9.2, 6.2, 8.2, 5.2, 3.2, 7.2, 4.2, 1.2, 2.1}, 
  /* Site 13 */ {7.3, 3.3, 1.3, 4.3, 5.3, 9.3, 10.3, 8.3, 2.3, 6.3}, 
  /* Site 14 */ {3.4, 4.4, 6.4, 9.4, 5.4, 10.4, 2.4, 1.4, 7.4, 8.4}, 
  /* Site 15 */ {5.5, 1.5, 6.5, 4.5, 10.5, 8.5, 7.5, 3.5, 2.5, 9.5}, 
  /* Site 16 */ {10.6, 4.6, 6.6, 5.6, 9.6, 8.6, 1.6, 3.6, 2.6, 7.6}, 
  /* Site 17 */ {3.7, 5.7, 10.7, 1.7, 9.7, 6.7, 7.7, 8.7, 2.7, 4.7}, 
  /* Site 18 */ {10.8, 1.8, 6.8, 4.8, 5.8, 3.8, 7.8, 8.8, 2.8, 9.8}, 
  /* Site 19 */ {1.9, 9.9, 6.9, 4.9, 5.9, 7.9, 3.9, 8.9, 2.9, 10.9}, 
  /* Site 20 */ {2.9, 5.4, 9.8, 5.5, 4.7, 2.3, 6.4, 7.8, 3.4, 4.5},
};

/* Station Capital Costs:
 * How much it costs to build a station
 */
float[] STATION_CAPITAL_COST = {
  /* Station  1 */ 55,
  /* Station  2 */ 45,
  /* Station  3 */ 40,
  /* Station  4 */ 45,
  /* Station  5 */ 50,
  /* Station  6 */ 45,
  /* Station  7 */ 35,
  /* Station  8 */ 40,
  /* Station  9 */ 50,
  /* Station 10 */ 60
};

/* Station Request Capacity:
 * How many units of "request" a station can handle per unit time
 */
float[] STATION_REQUEST_CAPACITY = {
  /* Station  1 */ 35,
  /* Station  2 */ 60,
  /* Station  3 */ 48,
  /* Station  4 */ 55,
  /* Station  5 */ 45,
  /* Station  6 */ 50,
  /* Station  7 */ 36,
  /* Station  8 */ 50,
  /* Station  9 */ 40,
  /* Station 10 */ 30
};

/* Total Refuse Requested for Pickup at Site:
 * Presumably over some fixed period of time (e.g. 1 year)
 */
float[] SITE_REQUESTED = {
  /* Site  1 */ 6, 
  /* Site  2 */ 6, 
  /* Site  3 */ 6,  
  /* Site  4 */ 6, 
  /* Site  5 */ 6,  
  /* Site  6 */ 6, 
  /* Site  7 */ 6, 
  /* Site  8 */ 6, 
  /* Site  9 */ 6, 
  /* Site 10 */ 6, 
  /* Site 11 */ 6, 
  /* Site 12 */ 6,  
  /* Site 13 */ 6, 
  /* Site 14 */ 6, 
  /* Site 15 */ 6, 
  /* Site 16 */ 6, 
  /* Site 17 */ 6, 
  /* Site 18 */ 6, 
  /* Site 19 */ 6, 
  /* Site 20 */ 6
};

// Genetic Algorithm Parameters
int numGenerations;
int childrenPerGeneration, grandChildrenPerGeneration;

// Each entry in the list is the most fit configuration settings or cost for a given generation
ArrayList<int[]> fittestStationConfiguration;
ArrayList<float[][]> fittestAllocation;
ArrayList<Float> fittestCost;

// This method runs once when the application is starting
void setup() {
  
  numGenerations = 100;
  childrenPerGeneration = 100;
  grandChildrenPerGeneration = 500;
  
  // Initial Station Configuration [ALL BUILT]:
  // This is obviously the most expensive and least efficient option to start with
  // So we expect to easily find better solutions
  // 0 = DO NOT BUILD; 1 = DO BUILD
  int[] stationConfiguration_0 = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
  
  // Initial allocation of refuse requests from sites to stations in the formation of an origin-destination matrix
  float[][] allocation_0 = initAllocation(stationConfiguration_0);
  
  // Initial cost is calculated using the station configuration and the request allocations
  float cost_0 = totalCost(stationConfiguration_0, allocation_0);
  
  // List to Record the "most fit" values for each generation
  fittestStationConfiguration = new ArrayList<int[]>();
  fittestAllocation = new ArrayList<float[][]>();
  fittestCost = new ArrayList<Float>();
  
  // Populate initial values of fit lists
  fittestStationConfiguration.add(stationConfiguration_0);
  fittestAllocation.add(allocation_0);
  fittestCost.add(cost_0);
  
  // Run Genetic Algorithm
  int currentGeneration = 0;
  while(currentGeneration < numGenerations) {
    
    // Settings for Previous Generation
    int[] parentStationConfig = fittestStationConfiguration.get(currentGeneration);
    float[][] parentAllocation = fittestAllocation.get(currentGeneration);
    
    // Evaluate next generation and add record the most fit child
    evalGrandChildren(parentStationConfig, parentAllocation, childrenPerGeneration, grandChildrenPerGeneration);
    
    // The following method was deprecated and replaced by "evalGrandChildren"
    //evalChildren(parentStationConfig, parentAllocation, childrenPerGeneration);
    
    currentGeneration++;
  }
  
  // Print Final Solution Summary to Console:
  int[] lastConfig = fittestStationConfiguration.get(numGenerations - 1);
  float[][] lastAllocation = fittestAllocation.get(numGenerations - 1);
  printStationConfiguration(lastConfig, lastAllocation);
  println(" ");
  printAllocation(lastAllocation);
  println("Over Capacity: " + overCapacity(lastConfig, lastAllocation));
  println("Total Cost: " + totalCost(lastConfig, lastAllocation));
  
  // Canvas Size
  size(1200, 600);
  
  // Draw Graph to Canvas
  drawGraph();
}

/* Generate and Evaluate Children of a single generation for Fitness
 */
public void evalChildren(int[] parentStationConfig, float[][] parentAllocation, int numChildren) {
  
  // Variables to store fittest child in this generation
  int[] fitStationConfiguration = parentStationConfig;
  float[][] fitAllocation = parentAllocation;
  float fitCost = totalCost(parentStationConfig, parentAllocation);
  
  // Small chance that stations will be mutated this generation instead of allocations
  boolean mutateStationConfig;
  if (random(1) < 0.10) {
    mutateStationConfig = true;
  } else {
    mutateStationConfig = false;
  }
  
  // Generate all of the offspring for current generation
  for(int i=0; i<numChildren; i++) {
    
    // Child Configuration
    int[] stationConfiguration;
    float[][] allocation;
    
    if(mutateStationConfig) {
      
      // Mutate the scenario's Station Configuration
      stationConfiguration = mutateStationConfiguration(parentStationConfig);
      allocation = reAllocate(stationConfiguration, parentAllocation);
    } else {
      
      // Mutation the scenario's Allocation for Requests while holding Station Configuration Constant
      stationConfiguration = parentStationConfig;
      allocation = mutateAllocation(parentStationConfig, parentAllocation);
    }
    // Calculate the cost of this child configuration
    float cost = totalCost(stationConfiguration, allocation);
    
    // Check if child is cheaper than all other children AND it's within capacity of all Stations
    // If so, update this child to be the most fit candidate
    if(cost <= fitCost && !overCapacity(stationConfiguration, allocation)) {
      fitStationConfiguration = stationConfiguration;
      fitAllocation = allocation;
      fitCost = cost;
    }
  }
  
  // Record the most fit child's configuration and cost as the result for this generation
  fittestStationConfiguration.add(fitStationConfiguration);
  fittestAllocation.add(fitAllocation);
  fittestCost.add(fitCost);
}

/* Generate and Evaluate Children and Grand Children of a single generation for Fitness
 */
public void evalGrandChildren(int[] parentStationConfig, float[][] parentAllocation, int numChildren, int numGrandChildren) {
  
  // Variables to store fittest child in this generation
  int[] fitStationConfiguration = parentStationConfig;
  float[][] fitAllocation = parentAllocation;
  float fitCost = totalCost(parentStationConfig, parentAllocation);
  
  // Generate all of the offspring for current generation
  for(int i=0; i<numChildren; i++) {
    
    // Child Configuration
    int[] stationConfiguration;
    float[][] allocation;
    
    // Chance that stations will be mutated this generation instead of allocations
    // tinkering with this value appears to have a pretty big impact on what solutions are discovered
    float mutationChance = 0.10; // 10%
    boolean mutateStationConfig;
    if (random(1) < mutationChance) { 
      mutateStationConfig = true;
    } else {
      mutateStationConfig = false;
    }
    
    if(mutateStationConfig) {
      
      // Mutate the scenario's Station Configuration
      stationConfiguration = mutateStationConfiguration(parentStationConfig);
      allocation = reAllocate(stationConfiguration, parentAllocation);
    } else {
      
      // Mutation the scenario's Allocation for Requests while holding Station Configuration Constant
      stationConfiguration = parentStationConfig;
      allocation = mutateAllocation(parentStationConfig, parentAllocation);
    }
    
    int[] fitStationConfigurationGrand = stationConfiguration;
    float[][] fitAllocationGrand = allocation;
    float fitCostGrand = totalCost(stationConfiguration, allocation);
    
    // Use grand children to select for allocation
    for(int j=0; j<numGrandChildren; j++) {
      allocation = mutateAllocation(stationConfiguration, fitAllocationGrand);
      
      // Calculate the cost of this child configuration
      float cost = totalCost(stationConfiguration, allocation);
      
      // Check if child is cheaper than all other children AND it's within capacity of all Stations
      // If so, update this child to be the most fit candidate
      if(cost <= fitCostGrand && !overCapacity(stationConfiguration, allocation)) {
        fitStationConfigurationGrand = stationConfiguration;
        fitAllocationGrand = allocation;
        fitCostGrand = cost;
      }
    }
    
    // Check if child is cheaper than all other children AND it's within capacity of all Stations
    // If so, update this child to be the most fit candidate
    if(fitCostGrand <= fitCost && !overCapacity(fitStationConfigurationGrand, fitAllocationGrand)) {
      fitStationConfiguration = fitStationConfigurationGrand;
      fitAllocation = fitAllocationGrand;
      fitCost = fitCostGrand;
    }
  }
  
  // Record the most fit child's configuration and cost as the result for this generation
  fittestStationConfiguration.add(fitStationConfiguration);
  fittestAllocation.add(fitAllocation);
  fittestCost.add(fitCost);
}

/* Initialize a matrix that distributes all site requests equally across all available stations
 * Each row (representing a site) should add up to site's total requests. 
 *
 * --Note that this method does not consider station capacity and may allocate 
 *   more requests to a station than it can handle!!!--
 */
float[][] initAllocation(int[] stationConfig) {
  
  // Total number of sites and stations
  int numSites = SITE_REQUESTED.length;
  int potentialStations = stationConfig.length;
  
  // Count number of stations being built
  int builtStations = 0;
  for(int i=0; i<stationConfig.length; i++) {
    builtStations += stationConfig[i];
  }
  
  // Fraction of total site requests given to each station
  float allocation_per_station = 1.0 / builtStations;
  
  // Create an empty matrix with the correct number of rows and columns
  float[][] allocation = new float[numSites][potentialStations];
  
  // Populate the matrix with each site's requests distributed equally across all stations
  for(int i=0; i<numSites; i++) {
    for(int j=0; j<potentialStations; j++) {
      if(stationConfig[j] == 1) { 
        // Allocate requests to built station
        allocation[i][j] = allocation_per_station * SITE_REQUESTED[i];
      } else { 
        // Do not allocate requests to unbuilt station
        allocation[i][j] = 0;
      }
    }
  }
  
  return allocation;
}

/* Adjust a matrix that distributes requests that are allocated to unbuilt stations
 * Each row (representing a site) should add up to site's total requests. 
 *
 * --Note that this method does not consider station capacity and may allocate 
 *   more requests to a station than it can handle!!!--
 *
 * --Note that this method assumes that only one station is ever deleted at a time!!!--
 */
float[][] reAllocate(int[] stationConfig, float[][] allocation) {
  
  // Count number of stations being built
  int builtStations = 0;
  for(int i=0; i<stationConfig.length; i++) {
    builtStations += stationConfig[i];
  }
  
  float[][] newAllocation = cloneMatrix(allocation);
  for(int i=0; i<newAllocation.length; i++) {
    for(int j=0; j<newAllocation[0].length; j++) {
      
      // Detect if requests need to be reallocated
      if(stationConfig[j] == 0 && newAllocation[i][j] > 0) {
        
        float portionSize = newAllocation[i][j] / builtStations;
        newAllocation[i][j] = 0;
        
        for(int k=0; k<newAllocation[i].length; k++) {
          if(stationConfig[k] == 1) {
            newAllocation[i][k] += portionSize;
          }
        }
      }
    }
  }
  
  return newAllocation;
}

/* Mutate the Station Configuration so that a random station is built or unbuilt
 */
public int[] mutateStationConfiguration(int[] stationConfig) {
  
  // Total number of stations
  int potentialStations = stationConfig.length;
  int[] childConfig = new int[potentialStations];
  
  // Count number of stations being built
  int builtStations = 0;
  for(int i=0; i<stationConfig.length; i++) {
    builtStations += stationConfig[i];
  }
  
  // Pick a random Station Slot Index
  int stationIndex = int(random(0, potentialStations));
  
  for(int i=0; i<potentialStations; i++) {
    if(stationIndex == i) {
      if(stationConfig[i] == 0) {
        // Build the station if it doesn't exist
        childConfig[i] = 1;
      } else if (stationConfig[i] == 1 && builtStations > 1) {
        // Deconstruct the building if it exists, unless it is the last station then leave it
        childConfig[i] = 0;
      }
    } else {
      // Leave station state unchanged otherwise
      childConfig[i] = 0 + stationConfig[i];
    }
  }
  
  return childConfig;
}

/* Mutate the stations allocation so that a portion of a single site's refuse 
 * request is transferred among other sites
 */
public float[][] mutateAllocation(int[] stationConfig, float[][] allocation) {
  
  // Total number of sites and stations
  int numSites = SITE_REQUESTED.length;
  int potentialStations = stationConfig.length;
  
  // Count number of stations being built
  int builtStations = 0;
  for(int i=0; i<stationConfig.length; i++) {
    builtStations += stationConfig[i];
  }
  
  // Amount by which to mutate a single value
  float jitter_station = random(-0.05, 0.05);
  
  // Choose a Random Site Index
  int randomSite = int(random(0, numSites));
  
  // Choose A Random Station, checking that it is Built
  int randomStation = -1;
  while(randomStation == -1) {
    int randomIndex = int(random(0, stationConfig.length));
    if (stationConfig[randomIndex] == 1) {
      randomStation = randomIndex;
    }
  }
  
  // Given the randomly selected site, reallocate the requests to the randomly selected station
  float[][] allocation_copy = cloneMatrix(allocation);
  for(int i=0; i<potentialStations; i++) {
    if(stationConfig[i] == 1) {
      if(i == randomStation) {
        allocation_copy[randomSite][i] += jitter_station;
      } else {
        allocation_copy[randomSite][i] -= jitter_station / (builtStations - 1);
      }
      
      // Check for Negative allocation
      if(allocation_copy[randomSite][i] < 0) {
        //println("Potential for negative Allocation Value Detected, Parent value returned");
        return allocation;
      }
    }
  }
  
  return allocation_copy;
}

/* Make a copy of an array
 */
public float[][] cloneMatrix(float[][] matrix) {
  float[][] clone = new float[matrix.length][matrix[0].length];
  for(int i=0; i<matrix.length; i++) {
    for(int j=0; j<matrix[0].length; j++) {
      clone[i][j] = 0 + matrix[i][j];
    }
  }
  return clone;
}

/* Test to see if any of the stations are over capacity
 * Note that a station that is not built is treated as a station with zero capacity
 */
public boolean overCapacity(int[] stationConfig, float[][] allocation) {
  
  // Total number of sites and stations
  int numSites = SITE_REQUESTED.length;
  int potentialStations = STATION_REQUEST_CAPACITY.length;
  
  // Total Requests allocated for each station initialized to zero
  float[] totalRequests = new float[potentialStations];
  for(int i=0; i<potentialStations; i++) {
    totalRequests[i] = 0;
  }
  
  // Calculate the Total Requests allocated for each station
  for(int i=0; i<numSites; i++) {
    for(int j=0; j<potentialStations; j++) {
      totalRequests[j] += allocation[i][j];
    }
  }
  
  // If any of the stations are over capacity, return false
  for(int i=0; i<potentialStations; i++) {
    if(totalRequests[i] > STATION_REQUEST_CAPACITY[i] * stationConfig[i] ) {
      return true;
    }
  }
  
  // Return false if all requests within capacity
  return false;
}

/* Get total requests aggregated by Station
 */
public float[] getTotalRequests(float[][] allocation) {
  
   // Total number of sites and stations
  int numSites = SITE_REQUESTED.length;
  int potentialStations = allocation[0].length;
  
  // Total Requests allocated for each station initialized to zero
  float[] totalRequests = new float[potentialStations];
  for(int i=0; i<potentialStations; i++) {
    totalRequests[i] = 0;
  }
  
  // Calculate the Total Requests allocated for each station
  for(int i=0; i<numSites; i++) {
    for(int j=0; j<potentialStations; j++) {
      totalRequests[j] += allocation[i][j];
    }
  }
  
  return totalRequests;
}

/* Calculate Total Cost of Configuration
 */
public float totalCost(int[] stationConfig, float[][] allocation) {
  
  // Total number of sites and stations
  int numSites = allocation.length;
  int potentialStations = stationConfig.length;
  
  // Calculate Capital Cost of Station Configuration
  float capitalCost = 0;
  for(int i=0; i<potentialStations; i++) {
    capitalCost += stationConfig[i] * STATION_CAPITAL_COST[i];
  }
  
  // Calculate Transportation Costs
  float transportCost = 0;
  for(int i=0; i<numSites; i++) {
    for(int j=0; j<potentialStations; j++) {
      transportCost += allocation[i][j] * TRANSPORT_COST_PER_REQUEST[i][j];
    }
  }
  
  return capitalCost + transportCost;
}

/* Print Station Configuration to console
 */
public void printStationConfiguration(int[] stationConfig, float[][] allocation) {
  
  // Get total requests aggregated by Station
  float[] totalRequests = getTotalRequests(allocation);
  
  // Initialize Counteres for Labels
  int station = 1;
  
  String text = "Station Status: \n";
  for(int i=0; i<stationConfig.length; i++) {
    text += "\n" + "Station " + station + ": ";
    if(stationConfig[i] == 1) {
      text += "BUILT";
      text += " [Capacity: " + int(100 * totalRequests[i] / STATION_REQUEST_CAPACITY[i]) + "%]";
    } else {
      text += "-";
    }
    station++;
  }
  
  println(text);
}

/* Print allocation of requests to console
 */
public void printAllocation(float[][] allocation) {
  
  // Initialize Counteres for Labels
  int site = 1;
  int station = 1;
  
  // Write Header row
  String header = "Origin-Destination Matrix for Requests: \n\n" + "SITE # " + "\t";
  for(int j=0; j<allocation[0].length; j++) {
    header += "ST" + station + "\t";
    station++;
  }
  header += "TOTAL";
  
  // Write Tabel Content
  String body = "";
  for(int i=0; i<allocation.length; i++) {
    String row = "SITE " + site + "\t";
    site++;
    float total = 0;
    for(int j=0; j<allocation[0].length; j++) {
      row += int(1000*allocation[i][j])/1000.0 + "\t";
      total += allocation[i][j];
    }
    row += int(1000*total)/1000.0;
    body += row + "\n";
  }
  
  println(header + "\n" + body);
}

/* Draw the plot of generation fitness
 */
public void drawGraph() {
  
  // Draw Graph
  int margin = 100;
  
  // Numeric Bounds
  int x_min = 0;
  int x_max = numGenerations;
  int y_min = 400;
  int y_max = 1500;
  
  // Styling
  background(255);
  stroke(0);
  textAlign(CENTER, CENTER);
  fill(0);
  
  // Draw Axes Lines
  line(margin, margin, margin, height - margin);
  line(margin, height - margin, width - margin, height - margin);
  
  // Y Axis Text
  pushMatrix(); 
  translate(0.75 * margin, 0.5 * height); 
  rotate(-0.5 * PI);
  text("Cost", 0, 0);
  popMatrix();
  text(y_min, 0.75 * margin, height - margin);
  text(y_max, 0.75 * margin, margin);
  
  // X Axis Text
  pushMatrix(); 
  translate(0.5 * width, height - 0.75 * margin); 
  text("Generation", 0, 0);
  popMatrix();
  text(x_min, margin, height - 0.75 * margin);
  text(x_max, width - margin, height - 0.75 * margin);
  
  // Plot Points
  fill(0, 100); noStroke(); 
  for(int i=0; i<fittestCost.size(); i++) {
    float x = margin + (width - 2 * margin) * i / float(numGenerations);
    float y = height - margin - (height - 2 * margin) * fittestCost.get(i) / 2000.0;
    circle(x, y, 2);
    if(i == fittestCost.size() - 1) {
      fill(0);
      text(fittestCost.get(i), x, y + 20);
    }
  }
}
