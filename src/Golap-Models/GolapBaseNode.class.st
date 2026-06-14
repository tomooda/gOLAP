Class {
	#name : 'GolapBaseNode',
	#superclass : 'Object',
	#instVars : [
		'data',
		'name'
	],
	#category : 'Golap-Models-Graph',
	#package : 'Golap-Models',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
GolapBaseNode class >> id: aString name: anotherString data: aDictionary [

	^ self new
		  data:
			  (DataSeries withKeys: aDictionary keys values: aDictionary values);
		  id: aString;
		  name: anotherString;
		  yourself
]

{ #category : 'instance creation' }
GolapBaseNode class >> on: aDataSeries name: aString [

	^ self new
		  data: aDataSeries;
		  name: aString;
		  yourself
]

{ #category : 'converting' }
GolapBaseNode >> asGolapNode [

	^ GolapNode on: data name: name
]

{ #category : 'accessing' }
GolapBaseNode >> data [

	^ data
]

{ #category : 'accessing' }
GolapBaseNode >> data: aDataSeries [

	data := aDataSeries
]

{ #category : 'accessing' }
GolapBaseNode >> id [

	^ data name
]

{ #category : 'accessing' }
GolapBaseNode >> id: aString [

	data name: aString
]

{ #category : 'accessing' }
GolapBaseNode >> name [

	^ name
]

{ #category : 'accessing' }
GolapBaseNode >> name: aString [

	name := aString asString
]
