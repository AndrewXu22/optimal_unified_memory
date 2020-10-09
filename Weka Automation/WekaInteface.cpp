#include <cstdlib>
#include <iostream>
#include <string>
#include <stdio.h>
#include <fstream>
#include <sstream>
using std::string;
using namespace std;

const string inputFileArffTempFile = "inputArff_xqwue.arff";  
const string trainFileArffTempFile = "trainArff_xqwue.arff";  
const string outputPredictionTempFile = "tempPredictions_xqwue.csv";  
const string inputPredictionTempFile = string("inputPrediction_xqwue.arff");  

bool checkIfAttribute(string line){
	if(line.length() >= 10 & line.substr(0, 10).compare(string("@attribute")) == 0){
		return true;
	}
	else{
		return false;
	}
		
}

bool checkIfData(string line){
	if(line.length() >= 5 & line.substr(0, 5).compare(string("@data")) == 0) {
		return true;
	}
	else{
		return false;
	}
		
}

string getModel(string modelChoice){
	string wekaModelCall;
	if(string("DecisionTree").compare(modelChoice) == 0){
		wekaModelCall = "weka.classifiers.trees.J48";
	}
	else if(string("RandomTree").compare(modelChoice) == 0){
		wekaModelCall = "weka.classifiers.trees.RandomTree";
	}
	else if(string("RandomForest").compare(modelChoice) == 0){
		wekaModelCall = "weka.classifiers.trees.RandomForest";
	}
	else if(string("REPtree").compare(modelChoice) == 0){
		wekaModelCall = "weka.classifiers.trees.REPtree";
	}
	else if(string("Bagging").compare(modelChoice) == 0){
		wekaModelCall = "weka.classifiers.meta.bagging";
	}
	else{
		std::cout << "Invalid Model";
		return "";
	}	
	return wekaModelCall;
}

void getPredictionCSV(string trainingFilename, string inputFilename){
	string line;
	
	ifstream trainFile(trainingFilename.c_str());
	
	std::ofstream inputPredictionCSV;
	inputPredictionCSV.open(inputPredictionTempFile.c_str());
	
	//Set title
	inputPredictionCSV << "@relation PredictionInput\n\n";
	
	//Get to attribute list
	getline(trainFile,line);
	while(!trainFile.bad() & !checkIfAttribute(line)){
		getline(trainFile,line);
	}
	
	//Copy over attributes
	while(!trainFile.bad() & checkIfAttribute(line)){
		inputPredictionCSV << line + string("\n");
		getline(trainFile,line);
	}

	inputPredictionCSV << string("\n@data\n");
	
	/*Reading from data to run predictions on */
	ifstream inputFile(inputFilename.c_str());
	
	getline(inputFile,line);
	while(!checkIfData(line)){
		getline(inputFile,line);
	}
	
	getline(inputFile,line);
	
	while(getline(inputFile,line)){
		inputPredictionCSV << line + string("\n");
	}
	
	return;
}

void formatPredictionOutputCSV(string outputFilename){
	string line,value;
	
	ifstream inputfile(outputPredictionTempFile.c_str());
	std::ofstream predictionCSV;
	predictionCSV.open(outputFilename.c_str());
	
	//Set column titles
	predictionCSV << "Instance,Predicted Value\n";
	
	for(int i = 0; i<5; i++){
		getline(inputfile,line);
	}
	
	while(getline(inputfile,line)){
		if (line.find(',') == std::string::npos){
			break;
		}
		
		std::stringstream  lineStream(line);
		getline(lineStream,value,',');
		predictionCSV << value + string(",");
		getline(lineStream,value,',');
		getline(lineStream,value,',');
		size_t predictionIndex = value.find_first_of(":"); 
		predictionCSV << value.substr(predictionIndex + 1, value.length()) + string("\n");
		
	}	
	
	remove(outputPredictionTempFile.c_str());
	return;
	
}

void buildModel(int argc, char **argv){
	string inputFilename = argv[2];
	string modelChoice = argv[3];
	string outputFilename = argv[4];
	
	//Check for model chosen
	string wekaModelCall = getModel(modelChoice);
	
	string wekaCall = string("java -cp weka.jar " ) + wekaModelCall +  string(" -t ") + inputFilename + string(" -d ") + outputFilename + string("_") + modelChoice + string(".model");
	
	//check for additional arguments
	if(argc > 4){
		for(int i = 5; i < argc; i++){
			wekaCall += argv[i];
		}
	}

	wekaCall += string(" >> output.txt");
	system(wekaCall.c_str());	
	remove("output.txt");
	return;
}

void testModel(int argc, char **argv){
	string modelFile= argv[2];
	string inputFilename = argv[3];
	
	size_t modelIndex = modelFile.find_last_of("_"); 
	size_t fileExtensionIndex = modelFile.find_last_of("."); 
	string modelChoice = modelFile.substr(modelIndex + 1, fileExtensionIndex - modelIndex - 1);

	//Check for model chosen
	string wekaModelCall = getModel(modelChoice);
	
	string wekaCall = string("java -cp weka.jar ") + wekaModelCall + string(" -l ") + modelFile + " -T " + inputFilename + string(" -o ");
	system(wekaCall.c_str());
	return;
}

void makePrediction(int argc, char **argv){
	string modelFile = argv[2];
	string trainingFilename = argv[3]; //added file used for training
	string inputFilename = argv[4];
	string outputFilename = argv[5];
	
	
	size_t modelIndex = modelFile.find_last_of("_"); 
	size_t fileExtensionIndex = modelFile.find_last_of("."); 
	string modelChoice = modelFile.substr(modelIndex + 1, fileExtensionIndex - modelIndex - 1);

	//Check for model chosen
	string wekaModelCall = getModel(modelChoice);

	//Make arff
	string firstWekaCall = string("java -cp weka.jar weka.core.converters.CSVLoader ") + inputFilename + string(" > ") + inputFileArffTempFile;
	system(firstWekaCall.c_str()); 

	string secondWekaCall = string("java -cp weka.jar weka.core.converters.CSVLoader ") + trainingFilename + string(" > ") + trainFileArffTempFile;
	system(secondWekaCall.c_str()); 
	
	getPredictionCSV(trainFileArffTempFile, inputFileArffTempFile);
	
	remove(inputFileArffTempFile.c_str());
	remove(trainFileArffTempFile.c_str());

	string wekaCall = string("java -cp weka.jar ") + wekaModelCall + string(" -l ") + modelFile + " -T " + inputPredictionTempFile + string(" -classifications weka.classifiers.evaluation.output.prediction.CSV >> ") + outputPredictionTempFile;
	system(wekaCall.c_str());

	formatPredictionOutputCSV(outputFilename + string(".csv"));
	remove(outputPredictionTempFile.c_str());
	remove(inputPredictionTempFile .c_str());
	return;
}

int main(int argc, char **argv) {
	string flag = argv[1];
	
	//Train Model
	if(string("-b").compare(flag) == 0){
		buildModel(argc,argv);
	}
	
	//Test Model
	else if(string("-t").compare(flag) == 0){
		testModel(argc,argv);
	}
	
	//Make Predictions
	else if(string("-p").compare(flag) == 0){
		makePrediction(argc,argv);
	}
	
	else{
		std::cout << "ERROR: Improper flag";
	}
return 0;

}



