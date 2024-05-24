Class {
	#name : 'GolapNodeNumEdgesEvaluator',
	#superclass : 'GolapNodeEvaluator',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'instance creation' }
GolapNodeNumEdgesEvaluator class >> fromJSON: aDictionary [

	^ aDictionary at: self tag ifPresent: [ self new ] ifAbsent: [ nil ]
]

{ #category : 'accessing' }
GolapNodeNumEdgesEvaluator class >> tag [

	^ 'degree'
]

{ #category : 'accessing' }
GolapNodeNumEdgesEvaluator >> name [

	^ '関連数 (degree)'
]

{ #category : 'accessing' }
GolapNodeNumEdgesEvaluator >> subtag [

	^ true
]

{ #category : 'evaluating' }
GolapNodeNumEdgesEvaluator >> value: aGolapNode graph: aGolapModel [

	^ aGolapNode numberOfEdges
]
