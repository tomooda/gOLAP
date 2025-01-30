Class {
	#name : 'GolapFilterNaryBooleanFunction',
	#superclass : 'GolapFilterBooleanFunction',
	#instVars : [
		'nodes'
	],
	#category : 'Golap-Query-StructuredEditor',
	#package : 'Golap-Query',
	#tag : 'StructuredEditor'
}

{ #category : 'instance creation' }
GolapFilterNaryBooleanFunction class >> withAll: anArrayOfGolapFilterNode [
	^ self new
		nodes: anArrayOfGolapFilterNode;
		yourself
]

{ #category : 'adding/removing' }
GolapFilterNaryBooleanFunction >> add: aGolapFilterNode [
	(nodes includes: aGolapFilterNode)
		ifFalse: [ aGolapFilterNode parent: self.
			nodes := nodes copyWith: aGolapFilterNode ].
	^ aGolapFilterNode
]

{ #category : 'accessing' }
GolapFilterNaryBooleanFunction >> golapQueryChildren [
	^ nodes
]

{ #category : 'testing' }
GolapFilterNaryBooleanFunction >> isValidGolapQuery [
	^ nodes notNil and: [ nodes size >= 2 ]
]

{ #category : 'accessing' }
GolapFilterNaryBooleanFunction >> nodes [
	^ nodes
]

{ #category : 'accessing' }
GolapFilterNaryBooleanFunction >> nodes: anArrayOfGolapFilterFunction [
	nodes
		ifNotNil: [ nodes do: [ :function | function parent: nil ] ].
	nodes := anArrayOfGolapFilterFunction.
	nodes
		ifNotNil: [ nodes do: [ :function | function parent: self ] ]
]

{ #category : 'printing' }
GolapFilterNaryBooleanFunction >> printGolapQueryOn: aStream [
	aStream
		nextPutAll: self operatorName;
		nextPut: $(.
	nodes
		ifNotNil: [ nodes
				do: [ :value | 
					aStream nextPut: $,.
					value printGolapQueryOn: aStream ] ].
	aStream nextPut: $)
]

{ #category : 'adding/removing' }
GolapFilterNaryBooleanFunction >> remove: aGolapFilterNode [
	(nodes includes: aGolapFilterNode)
		ifTrue: [ aGolapFilterNode parent: nil.
			nodes := nodes copyWithout: aGolapFilterNode ].
	^ aGolapFilterNode
]
