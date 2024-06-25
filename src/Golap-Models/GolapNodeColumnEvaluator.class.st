Class {
	#name : 'GolapNodeColumnEvaluator',
	#superclass : 'GolapNodeEvaluator',
	#instVars : [
		'column'
	],
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'instance creation' }
GolapNodeColumnEvaluator class >> column: aString [

	^ self new
		  column: aString;
		  yourself
]

{ #category : 'instance creation' }
GolapNodeColumnEvaluator class >> fromJSON: aDictionary [

	^ aDictionary
		  at: self tag
		  ifPresent: [ :column | self column: column ]
		  ifAbsent: [ nil ]
]

{ #category : 'instance creation' }
GolapNodeColumnEvaluator class >> on: aGolapModel column: aString [

	^ (self on: aGolapModel)
		  column: aString;
		  yourself
]

{ #category : 'accessing' }
GolapNodeColumnEvaluator class >> tag [

	^ 'column'
]

{ #category : 'comparing' }
GolapNodeColumnEvaluator >> = anObject [

	^ self class = anObject class and: [ column = anObject column ]
]

{ #category : 'accessing' }
GolapNodeColumnEvaluator >> column [

	^ column
]

{ #category : 'accessing' }
GolapNodeColumnEvaluator >> column: aString [

	column := aString
]

{ #category : 'comparing' }
GolapNodeColumnEvaluator >> hash [

	^ self class hash bitXor: column hash
]

{ #category : 'accessing' }
GolapNodeColumnEvaluator >> name [

	^ column ifNil: [ '-' ]
]

{ #category : 'printing' }
GolapNodeColumnEvaluator >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	column printOn: aStream.
	aStream nextPut: $)
]

{ #category : 'accessing' }
GolapNodeColumnEvaluator >> subtag [

	^ column
]

{ #category : 'evaluating' }
GolapNodeColumnEvaluator >> value: aGolapNode graph: aGolapModel [

	^ aGolapNode at: column ifAbsent: [ 0 ]
]
