Class {
	#name : 'GolapFriendClusteredLayouter',
	#superclass : 'GolapLayouter',
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'accessing' }
GolapFriendClusteredLayouter >> layout [

	| tree numNodes minValue maxValue thetaScale rScale r0 |
	tree := (GolapHierarchicalClustering on: model)
		        rank: 2;
		        rank: 4;
		        rank: 8;
		        rank: 16;
		        rank: 32;
		        rank: 64;
		        rank: 128;
		        rank: 256;
		        tree.
	tree ifEmpty: [ ^ self ].
	tree sort.
	numNodes := tree size.
	divisions := numNodes * 3.
	minValue := maxValue := tree oneLeaf score.
	tree leavesDo: [ :leaf |
		| score |
		score := leaf score.
		minValue := minValue min: score.
		maxValue := maxValue max: score ].
	thetaScale := 2.0 * Float pi / numNodes asFloat.
	rScale := 0.6 / (maxValue - minValue) * numNodes.
	r0 := 0.4 * numNodes.
	tree leavesWithIndexDo: [ :leaf :index |
		| theta r |
		theta := (index - 1) asFloat * thetaScale.
		r := leaf score - minValue * rScale + r0.
		self
			move: leaf graphNode
			toX: theta cos * r + numNodes
			y: theta sin * r + numNodes ]
]
