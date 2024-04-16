Class {
	#name : #GolapVertexColumnEvaluator,
	#superclass : #GolapVertexEvaluator,
	#instVars : [
		'column'
	],
	#category : #'Golap-Models-Evaluator'
}

{ #category : #'instance creation' }
GolapVertexColumnEvaluator class >> column: aString [

	^ self new
		  column: aString;
		  yourself
]

{ #category : #'instance creation' }
GolapVertexColumnEvaluator class >> on: aGolapModel column: aString [

	^ (self on: aGolapModel)
		  column: aString;
		  yourself
]

{ #category : #accessing }
GolapVertexColumnEvaluator >> column [

	^ column
]

{ #category : #accessing }
GolapVertexColumnEvaluator >> column: aString [

	column := aString
]

{ #category : #accessing }
GolapVertexColumnEvaluator >> name [

	^ column ifNil: [ '-' ]
]

{ #category : #evaluating }
GolapVertexColumnEvaluator >> value: aGolapVertex [

	^ aGolapVertex at: column
]
