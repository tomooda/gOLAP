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

	| v1 v2 v3 v4 v5 v6 |
	model := GolapModel new.
	v1 := model vertices at: 1 put: (model
			       createVertex:
			       (DataSeries withKeys: { 'value' } values: { 10 } name: 1)
			       name: 'v1').
	v2 := model vertices at: 2 put: (model
			       createVertex:
			       (DataSeries withKeys: { 'value' } values: { 20 } name: 2)
			       name: 'v2').
	v3 := model vertices at: 3 put: (model
			       createVertex:
			       (DataSeries withKeys: { 'value' } values: { 30 } name: 3)
			       name: 'v3').
	v4 := model vertices at: 4 put: (model
			       createVertex:
			       (DataSeries withKeys: { 'value' } values: { 40 } name: 4)
			       name: 'v4').
	v5 := model vertices at: 5 put: (model
			       createVertex:
			       (DataSeries withKeys: { 'value' } values: { 50 } name: 5)
			       name: 'v5').
	v6 := model vertices at: 6 put: (model
			       createVertex:
			       (DataSeries withKeys: { 'value' } values: { 60 } name: 6)
			       name: 'v6').
	v1
		createEdgeTo: v2
		data:
		(DataSeries withKeys: { 'name'. 'value' } values: { 'e12'. 12 }).
	v2
		createEdgeTo: v3
		data:
		(DataSeries withKeys: { 'name'. 'value' } values: { 'e23'. 23 }).
	v3
		createEdgeTo: v1
		data:
		(DataSeries withKeys: { 'name'. 'value' } values: { 'e31'. 31 }).
	v4
		createEdgeTo: v5
		data:
		(DataSeries withKeys: { 'name'. 'value' } values: { 'e45'. 45 })
]

{ #category : 'tests' }
GolapModelTest >> testDiff [

	| baseModel v1 v2 v4 v8 |
	baseModel := GolapModel new.
	v1 := baseModel vertices at: 1 put: (baseModel
			       createVertex:
			       (DataSeries withKeys: { 'value' } values: { 100 } name: 1)
			       name: 'v1').
	v2 := baseModel vertices at: 2 put: (baseModel
			       createVertex:
			       (DataSeries withKeys: { 'value' } values: { 200 } name: 2)
			       name: 'v2').
	v4 := baseModel vertices at: 4 put: (baseModel
			       createVertex:
			       (DataSeries withKeys: { 'value' } values: { 400 } name: 4)
			       name: 'v4').
	v8 := baseModel vertices at: 8 put: (baseModel
			       createVertex:
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
	self assert: ((model vertexAt: 1) at: 'value') equals: -90.
	self assert: ((model vertexAt: 2) at: 'value') equals: -180.
	self assert: ((model vertexAt: 3) at: 'value') equals: 30.
	self assert: ((model vertexAt: 4) at: 'value') equals: -360.
	self assert: ((model vertexAt: 5) at: 'value') equals: 50.
	self assert: ((model vertexAt: 6) at: 'value') equals: 60.
	self assert: ((model vertexAt: 8) at: 'value') equals: -800.
	self
		assert:
			(((model vertexAt: 1) edgeTo: (model vertexAt: 2) ifAbsent: [  ])
				 at: 'value')
		equals: -108.
	self
		assert:
			(((model vertexAt: 2) edgeTo: (model vertexAt: 3) ifAbsent: [  ])
				 at: 'value')
		equals: 23.
	self
		assert:
			(((model vertexAt: 3) edgeTo: (model vertexAt: 1) ifAbsent: [  ])
				 at: 'value')
		equals: 31.
	self
		assert:
			(((model vertexAt: 4) edgeTo: (model vertexAt: 5) ifAbsent: [  ])
				 at: 'value')
		equals: 45.
	self
		assert:
			(((model vertexAt: 1) edgeTo: (model vertexAt: 4) ifAbsent: [  ])
				 at: 'value')
		equals: -140.
	self
		assert:
			(((model vertexAt: 1) edgeTo: (model vertexAt: 8) ifAbsent: [  ])
				 at: 'value')
		equals: -180
]

{ #category : 'tests' }
GolapModelTest >> testPostCopy [

	| copy |
	copy := model copy.
	1 to: 6 do: [ :id |
		self assert: (copy vertexAt: id) id equals: id.
		self deny: (copy vertexAt: id) identicalTo: (model vertexAt: id).
		(model vertexAt: id) data at: 'value' put: 0.
		self assert: ((copy vertexAt: id) at: 'value') equals: id * 10 ].
	self assert: (copy vertexAt: 1) numberOfEdges equals: 2.
	self assert: (copy vertexAt: 2) numberOfEdges equals: 2.
	self assert: (copy vertexAt: 3) numberOfEdges equals: 2.
	self assert: (copy vertexAt: 4) numberOfEdges equals: 1.
	self assert: (copy vertexAt: 5) numberOfEdges equals: 1.
	self assert: (copy vertexAt: 6) numberOfEdges equals: 0.
	{
		(1 -> 2).
		(2 -> 3).
		(3 -> 1).
		(4 -> 5) } do: [ :assoc |
		| id1 id2 edge |
		id1 := assoc key.
		id2 := assoc value.
		edge := (copy vertexAt: id1)
			        edgeTo: (copy vertexAt: id2)
			        ifAbsent: [ nil ].
		self
			assert: (edge at: 'name')
			equals: 'e' , id1 printString , id2 printString.
		self
			deny: edge
			identicalTo:
			((model vertexAt: id1)
				 edgeTo: (model vertexAt: id2)
				 ifAbsent: [ nil ]).
		((model vertexAt: id1)
			 edgeTo: (model vertexAt: id2)
			 ifAbsent: [ nil ]) data at: 'value' put: 0.
		self assert: (edge at: 'value') equals: id1 * 10 + id2 ]
]
