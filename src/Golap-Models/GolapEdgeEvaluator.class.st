Class {
	#name : #GolapEdgeEvaluator,
	#superclass : #Object,
	#instVars : [
		'golapModel'
	],
	#category : #'Golap-Models-Evaluator'
}

{ #category : #testing }
GolapEdgeEvaluator class >> isAbstract [

	^ self = GolapEdgeEvaluator
]

{ #category : #'instance creation' }
GolapEdgeEvaluator class >> on: aGolapModel [

	^ self new
		  golapModel: aGolapModel;
		  yourself
]

{ #category : #converting }
GolapEdgeEvaluator >> asSortFunction [

	^ PropertySortFunction property: self
]

{ #category : #sorting }
GolapEdgeEvaluator >> ascending [

	^ self asSortFunction
]

{ #category : #sorting }
GolapEdgeEvaluator >> descending [

	^ self asSortFunction reversed
]

{ #category : #accessing }
GolapEdgeEvaluator >> golapModel [

	^ golapModel
]

{ #category : #accessing }
GolapEdgeEvaluator >> golapModel: aGolapModel [

	golapModel := aGolapModel
]

{ #category : #accessing }
GolapEdgeEvaluator >> name [

	^ self subclassResponsibility
]

{ #category : #evaluating }
GolapEdgeEvaluator >> value: aGolapEdge [

	^ self subclassResponsibility
]
