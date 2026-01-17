Class {
	#name : 'GolapAddMarker',
	#superclass : 'GolapAbstractMarker',
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'accessing' }
GolapAddMarker >> activatedIn: aGolapItemList [

	aGolapItemList addMarkerColor
]

{ #category : 'adding-removing' }
GolapAddMarker >> addNode: aGolapNode [

	^ nil
]

{ #category : 'accessing' }
GolapAddMarker >> color [

	^ nil
]

{ #category : 'snapshot' }
GolapAddMarker >> fromJSON: aDictionary [

	
]

{ #category : 'accessing' }
GolapAddMarker >> icon [

	^ Smalltalk ui iconNamed: #add
]

{ #category : 'testing' }
GolapAddMarker >> includesNodeId: anObject [

	^ false
]

{ #category : 'accessing' }
GolapAddMarker >> queryString [

	^ ''
]

{ #category : 'accessing' }
GolapAddMarker >> queryString: aString in: aGolapItemList [

	
]

{ #category : 'adding-removing' }
GolapAddMarker >> removeNode: aGolapNode [

	^ nil
]

{ #category : 'updating' }
GolapAddMarker >> updateIn: aGolapItemList [

	
]
