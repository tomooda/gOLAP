Class {
	#name : 'GolapModelTest',
	#superclass : 'TestCase',
	#instVars : [
		'model'
	],
	#category : 'Golap-Models-Tests',
	#package : 'Golap-Models',
	#tag : 'Tests'
}

{ #category : 'running' }
GolapModelTest >> setUp [

	model := GolapModel fromJSON: {
			         ('nodes' -> {
				          {
					          ('id' -> 1).
					          ('name' -> 'v1').
					          ('data'
					           -> (DataSeries withKeys: { 'value' } values: { 10 })) }
					          asDictionary.
				          {
					          ('id' -> 2).
					          ('name' -> 'v2').
					          ('data'
					           -> (DataSeries withKeys: { 'value' } values: { 20 })) }
					          asDictionary.
				          {
					          ('id' -> 3).
					          ('name' -> 'v3').
					          ('data'
					           -> (DataSeries withKeys: { 'value' } values: { 30 })) }
					          asDictionary.
				          {
					          ('id' -> 4).
					          ('name' -> 'v4').
					          ('data'
					           -> (DataSeries withKeys: { 'value' } values: { 40 })) }
					          asDictionary.
				          {
					          ('id' -> 5).
					          ('name' -> 'v5').
					          ('data'
					           -> (DataSeries withKeys: { 'value' } values: { 50 })) }
					          asDictionary.
				          {
					          ('id' -> 6).
					          ('name' -> 'v6').
					          ('data'
					           -> (DataSeries withKeys: { 'value' } values: { 60 })) }
					          asDictionary }).
			         ('edges' -> {
				          {
					          ('node1' -> 1).
					          ('node2' -> 2).
					          ('data'
					           ->
					           (DataSeries
						            withKeys: { 'name'. 'value' }
						            values: { 'e12'. 12 })) } asDictionary.
				          {
					          ('node1' -> 2).
					          ('node2' -> 3).
					          ('data'
					           ->
					           (DataSeries
						            withKeys: { 'name'. 'value' }
						            values: { 'e23'. 23 })) } asDictionary.
				          {
					          ('node1' -> 3).
					          ('node2' -> 1).
					          ('data'
					           ->
					           (DataSeries
						            withKeys: { 'name'. 'value' }
						            values: { 'e31'. 31 })) } asDictionary.
				          {
					          ('node1' -> 4).
					          ('node2' -> 5).
					          ('data'
					           ->
					           (DataSeries
						            withKeys: { 'name'. 'value' }
						            values: { 'e45'. 45 })) } asDictionary }).
			         ('nodeEvaluator' -> { ('column' -> 'value') } asDictionary).
			         ('nodeAggregators'
			          -> { { ('aggregation' -> 'sum') } asDictionary }).
			         ('edgeEvaluator' -> { ('column' -> 'value') } asDictionary).
			         ('edgeAggregators'
			          -> { { ('aggregation' -> 'sum') } asDictionary }) }
			         asDictionary
]

{ #category : 'tests' }
GolapModelTest >> testDiff [

	| baseModel v1 v2 v4 v8 |
	baseModel := GolapModel new.
	v1 := baseModel nodes at: 1 put: (baseModel
			       createNode:
			       (DataSeries withKeys: { 'value' } values: { 100 } name: 1)
			       name: 'v1').
	v2 := baseModel nodes at: 2 put: (baseModel
			       createNode:
			       (DataSeries withKeys: { 'value' } values: { 200 } name: 2)
			       name: 'v2').
	v4 := baseModel nodes at: 4 put: (baseModel
			       createNode:
			       (DataSeries withKeys: { 'value' } values: { 400 } name: 4)
			       name: 'v4').
	v8 := baseModel nodes at: 8 put: (baseModel
			       createNode:
			       (DataSeries withKeys: { 'value' } values: { 800 } name: 8)
			       name: 'v8').
	v1
		createEdgeTo: v2
		data:
		(DataSeries withKeys: { 'name'. 'value' } values: { 'e12'. 120 }).
	v1
		createEdgeTo: v4
		data:
		(DataSeries withKeys: { 'name'. 'value' } values: { 'e14'. 140 }).
	v1
		createEdgeTo: v8
		data:
		(DataSeries withKeys: { 'name'. 'value' } values: { 'e18'. 180 }).
	model diff: baseModel.
	self assert: ((model nodeAt: 1) at: 'value') equals: -90.
	self assert: ((model nodeAt: 2) at: 'value') equals: -180.
	self assert: ((model nodeAt: 3) at: 'value') equals: 30.
	self assert: ((model nodeAt: 4) at: 'value') equals: -360.
	self assert: ((model nodeAt: 5) at: 'value') equals: 50.
	self assert: ((model nodeAt: 6) at: 'value') equals: 60.
	self assert: ((model nodeAt: 8) at: 'value') equals: -800.
	self
		assert:
			(((model nodeAt: 1) edgeTo: (model nodeAt: 2) ifAbsent: [  ])
				 at: 'value')
		equals: -108.
	self
		assert:
			(((model nodeAt: 2) edgeTo: (model nodeAt: 3) ifAbsent: [  ])
				 at: 'value')
		equals: 23.
	self
		assert:
			(((model nodeAt: 3) edgeTo: (model nodeAt: 1) ifAbsent: [  ])
				 at: 'value')
		equals: 31.
	self
		assert:
			(((model nodeAt: 4) edgeTo: (model nodeAt: 5) ifAbsent: [  ])
				 at: 'value')
		equals: 45.
	self
		assert:
			(((model nodeAt: 1) edgeTo: (model nodeAt: 4) ifAbsent: [  ])
				 at: 'value')
		equals: -140.
	self
		assert:
			(((model nodeAt: 1) edgeTo: (model nodeAt: 8) ifAbsent: [  ])
				 at: 'value')
		equals: -180
]

{ #category : 'tests' }
GolapModelTest >> testPostCopy [

	| copy |
	copy := model copy.
	1 to: 6 do: [ :i |
			| id |
			id := i asString.
			self assert: (copy nodeAt: id) id equals: id.
			self deny: (copy nodeAt: id) identicalTo: (model nodeAt: id).
			(model nodeAt: id) data at: 'value' put: 0.
			self assert: ((copy nodeAt: id) at: 'value') equals: i * 10 ].
	self assert: (copy nodeAt: '1') numberOfEdges equals: 2.
	self assert: (copy nodeAt: '2') numberOfEdges equals: 2.
	self assert: (copy nodeAt: '3') numberOfEdges equals: 2.
	self assert: (copy nodeAt: '4') numberOfEdges equals: 1.
	self assert: (copy nodeAt: '5') numberOfEdges equals: 1.
	self assert: (copy nodeAt: '6') numberOfEdges equals: 0.
	{
		(1 -> 2).
		(2 -> 3).
		(3 -> 1).
		(4 -> 5) } do: [ :assoc |
			| i1 i2 id1 id2 edge |
			i1 := assoc key.
			i2 := assoc value.
			id1 := i1 asString.
			id2 := i2 asString.
			edge := (copy nodeAt: id1)
				        edgeTo: (copy nodeAt: id2)
				        ifAbsent: [ nil ].
			self assert: (edge at: 'name') equals: 'e' , id1 , id2.
			self
				deny: edge
				identicalTo:
				((model nodeAt: id1) edgeTo: (model nodeAt: id2) ifAbsent: [ nil ]).
			((model nodeAt: id1) edgeTo: (model nodeAt: id2) ifAbsent: [ nil ])
				data at: 'value' put: 0.
			self assert: (edge at: 'value') equals: i1 * 10 + i2 ]
]
