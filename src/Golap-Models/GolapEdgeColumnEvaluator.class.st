Class {
	#name : #GolapEdgeColumnEvaluator,
	#superclass : #GolapEdgeEvaluator,
	#instVars : [
		'column'
	],
	#category : #'Golap-Models-Evaluator'
}

{ #category : #'instance creation' }
GolapEdgeColumnEvaluator class >> column: aString [

	^ self new
		  column: aString;
		  yourself
]

{ #category : #'instance creation' }
GolapEdgeColumnEvaluator class >> on: aGolapModel column: aString [

	^ (self on: aGolapModel)
		  column: aString;
		  yourself
]

{ #category : #accessing }
GolapEdgeColumnEvaluator >> column [

	^ column
]

{ #category : #accessing }
GolapEdgeColumnEvaluator >> column: aString [

	column := aString
]

{ #category : #accessing }
GolapEdgeColumnEvaluator >> name [

	^ column ifNil: '-'
]

{ #category : #evaluating }
GolapEdgeColumnEvaluator >> value: aGolapEdge [

	^ aGolapEdge at: column
]
