Class {
	#name : 'GolapVertexColumnEvaluator',
	#superclass : 'GolapVertexEvaluator',
	#instVars : [
		'column'
	],
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'instance creation' }
GolapVertexColumnEvaluator class >> column: aString [

	^ self new
		  column: aString;
		  yourself
]

{ #category : 'instance creation' }
GolapVertexColumnEvaluator class >> fromJSON: aDictionary [

	^ aDictionary
		  at: self tag
		  ifPresent: [ :column | self column: column ]
		  ifAbsent: [ nil ]
]

{ #category : 'instance creation' }
GolapVertexColumnEvaluator class >> on: aGolapModel column: aString [

	^ (self on: aGolapModel)
		  column: aString;
		  yourself
]

{ #category : 'accessing' }
GolapVertexColumnEvaluator class >> tag [

	^ 'column'
]

{ #category : 'accessing' }
GolapVertexColumnEvaluator >> column [

	^ column
]

{ #category : 'accessing' }
GolapVertexColumnEvaluator >> column: aString [

	column := aString
]

{ #category : 'accessing' }
GolapVertexColumnEvaluator >> name [

	^ column ifNil: [ '-' ]
]

{ #category : 'accessing' }
GolapVertexColumnEvaluator >> subtag [

	^ column
]

{ #category : 'evaluating' }
GolapVertexColumnEvaluator >> value: aGolapVertex [

	^ aGolapVertex at: column
]
