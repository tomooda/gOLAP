Class {
	#name : 'GolapOverviewGridLayouterTest',
	#superclass : 'TestCase',
	#category : 'Golap-Visualization-Tests',
	#package : 'Golap-Visualization',
	#tag : 'Tests'
}

{ #category : 'testdata' }
GolapOverviewGridLayouterTest >> nodesAndNoEdge [

	^ {
		  {
			  (GolapNode on: (DataSeries new name: 'node1') name: 'node1').
			  (GolapNode on: (DataSeries new name: 'node2') name: 'node2').
			  (GolapNode on: (DataSeries new name: 'node3') name: 'node3').
			  (GolapNode on: (DataSeries new name: 'node4') name: 'node4') }.
		  {  } }
]

{ #category : 'tests' }
GolapOverviewGridLayouterTest >> testLayoutNodesEdges [

	GolapOverviewGridLayouter new
		layoutNodes: {
				(GolapNode on: (DataSeries new name: 'node1') name: 'node1').
				(GolapNode on: (DataSeries new name: 'node2') name: 'node2').
				(GolapNode on: (DataSeries new name: 'node3') name: 'node3').
				(GolapNode on: (DataSeries new name: 'node4') name: 'node4') }
		edges: {  }
]
