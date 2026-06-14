Class {
	#name : 'GolapBaseEdge',
	#superclass : 'Object',
	#instVars : [
		'node1',
		'node2',
		'data'
	],
	#category : 'Golap-Models-Graph',
	#package : 'Golap-Models',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
GolapBaseEdge class >> node1: aString node2: anotherString data: aDictionary [

	^ self new
		  node1: aString;
		  node2: anotherString;
		  data: aDictionary;
		  yourself
]

{ #category : 'accessing' }
GolapBaseEdge >> data [

	^ data
]

{ #category : 'accessing' }
GolapBaseEdge >> data: aDataSeries [

	data := aDataSeries
]

{ #category : 'accessing' }
GolapBaseEdge >> node1 [

	^ node1
]

{ #category : 'accessing' }
GolapBaseEdge >> node1: aString [

	node1 := aString
]

{ #category : 'accessing' }
GolapBaseEdge >> node2 [

	^ node2
]

{ #category : 'accessing' }
GolapBaseEdge >> node2: aString [

	node2 := aString
]
