Class {
	#name : 'GolapEdgeColumnEvaluator',
	#superclass : 'GolapEdgeEvaluator',
	#instVars : [
		'column'
	],
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'instance creation' }
GolapEdgeColumnEvaluator class >> column: aString [

	^ self new
		  column: aString;
		  yourself
]

{ #category : 'instance creation' }
GolapEdgeColumnEvaluator class >> fromJSON: aDictionary [

	^ aDictionary
		  at: self tag
		  ifPresent: [ :column | self column: column ]
		  ifAbsent: [ nil ]
]

{ #category : 'instance creation' }
GolapEdgeColumnEvaluator class >> on: aGolapModel column: aString [

	^ (self on: aGolapModel)
		  column: aString;
		  yourself
]

{ #category : 'accessing' }
GolapEdgeColumnEvaluator class >> tag [

	^ 'column'
]

{ #category : 'accessing' }
GolapEdgeColumnEvaluator >> column [

	^ column
]

{ #category : 'accessing' }
GolapEdgeColumnEvaluator >> column: aString [

	column := aString
]

{ #category : 'accessing' }
GolapEdgeColumnEvaluator >> name [

	^ column ifNil: '-'
]

{ #category : 'accessing' }
GolapEdgeColumnEvaluator >> subtag [

	^ column
]

{ #category : 'evaluating' }
GolapEdgeColumnEvaluator >> value: aGolapEdge [

	^ aGolapEdge at: column
]
