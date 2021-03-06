package enterprise.utils;

import enterprise.facts.*;

public class VariableInfoProvider {


	String schemaName;

	public def createFact(dd) {
		def cf = null;	
		if(dd.datatype == "integer") {
			if(!createIntegerFact) createIntegerFact = { new enterprise.facts.IntegerInfo() };
			cf = createIntegerFact();
		}
		else if(dd.datatype == "decimal") {
			if(!createDecimalFact) createDecimalFact = { new enterprise.facts.DecimalInfo() };
			cf = createDecimalFact();
		}
		else if(dd.datatype == "boolean") {
			if(!createBooleanFact) createBooleanFact = { new enterprise.facts.BooleanInfo() };
			cf = createBooleanFact();
		}
		else if(dd.datatype == "string") {
			if(!createStringFact) createStringFact = { new enterprise.facts.StringInfo() };
			cf = createStringFact();
		}
		else if(dd.datatype == "date") {
			if(!createDateFact) 
				throw new Exception("createDateFact not implemented");
			cf = createDateFact();
		}
		else {
			if(!createObjectFact) 
				throw new Exception("createObjectFact not implemented");
			cf = createObjectFact();
		}
		
		//copy the data of the fact;
		cf.copy(dd);
		return cf;
	};

	def createDecimalFact;
	def createIntegerFact ;
	def createBooleanFact;
	def createStringFact;
	def createDateFact;
	def createObjectFact;

}