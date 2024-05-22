Class {
	#name : 'GolapNodeMaxEvaluator',
	#superclass : 'GolapNodeAggregationEvaluator',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'accessing' }
GolapNodeMaxEvaluator class >> subtag [

	^ 'max'
]

{ #category : 'evaluating' }
GolapNodeMaxEvaluator >> aggregation [

	^ #max
]

{ #category : 'accessing' }
GolapNodeMaxEvaluator >> aggregationName [

	^ '最大 '
]
