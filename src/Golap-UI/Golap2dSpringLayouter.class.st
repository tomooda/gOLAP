Class {
	#name : 'Golap2dSpringLayouter',
	#superclass : 'GolapLayouter',
	#instVars : [
		'softDivisions'
	],
	#category : 'Golap-UI-Layouter',
	#package : 'Golap-UI',
	#tag : 'Layouter'
}

{ #category : 'layouting' }
Golap2dSpringLayouter >> adjustCenter: aCollectionOfGolapNode [

	| numNodes minX minY maxX maxY meanX meanY |
	numNodes := aCollectionOfGolapNode size.
	minX := maxX := divisions asFloat * 0.5.
	minY := maxY := divisions asFloat * 0.5.
	aCollectionOfGolapNode do: [ :node |
		| x y |
		x := node x.
		y := node y.
		minX := minX min: x.
		maxX := maxX max: x.
		minY := minY min: y.
		maxY := maxY max: y ].
	meanX := 0.0.
	meanY := 0.0.
	aCollectionOfGolapNode do: [ :node |
		meanX := meanX + node x.
		meanY := meanY + node y ].
	meanX := divisions asFloat * 0.5
	         - (meanX / (numNodes max: 1) asFloat).
	meanY := divisions asFloat * 0.5
	         - (meanY / (numNodes max: 1) asFloat).
	aCollectionOfGolapNode do: [ :node |
		self move: node toX: node x + meanX y: node y + meanY ]
]

{ #category : 'layouting' }
Golap2dSpringLayouter >> bindParticles: aCollectionOfGolapNode bindings: bindings [

	| velocities |
	velocities := IdentityDictionary new: aCollectionOfGolapNode size.
	aCollectionOfGolapNode do: [ :node |
		velocities at: node put: 0.0 @ 0.0 ].
	aCollectionOfGolapNode do: [ :v1 |
		| p1 |
		p1 := v1 asPoint.
		(bindings at: v1) do: [ :v2 |
			| p2 v |
			p2 := v2 asPoint.
			v := p2 - p1.
			v r > 0.2 ifTrue: [
				velocities
					at: v1
					put: (velocities at: v1) + (p2 - (v normalized * 0.2) - p1) ] ] ].
	velocities keysAndValuesDo: [ :node :p |
		| numBindings |
		numBindings := (bindings at: node) size asFloat.
		numBindings > 1.0e-8 ifTrue: [
			self
				move: node
				toX: (node x + (p x / (bindings at: node) size asFloat)
						 min: softDivisions
						 max: 1.0e-8)
				y: (node y + (p y / (bindings at: node) size asFloat)
						 min: softDivisions
						 max: 1.0e-8) ] ]
]

{ #category : 'layouting' }
Golap2dSpringLayouter >> bindings [
	| bindings |
	bindings := IdentityDictionary new.
	model
		ifNotNil: [ model
				bindingEdgesDo: [ :edge | 
					| v1 v2 |
					v1 := edge node1.
					v2 := edge node2.
					v1 ~~ v2
						ifTrue: [ (bindings at: v1 ifAbsentPut: [ OrderedCollection new ]) add: v2.
							(bindings at: v2 ifAbsentPut: [ OrderedCollection new ])
								add: v1 ] ].
			model
				nodesDo: [ :v | bindings at: v ifAbsentPut: [ OrderedCollection new ] ] ].
	^ bindings
]

{ #category : 'layouting' }
Golap2dSpringLayouter >> centralize: aCollectionOfGolapNode [

	aCollectionOfGolapNode do: [ :node |
		self
			move: node
			toX: node x - (divisions * 0.5) * 0.99 + (divisions * 0.5)
			y: node y - (divisions * 0.5) * 0.99 + (divisions * 0.5) ]
]

{ #category : 'layouting' }
Golap2dSpringLayouter >> layout [
	self model ifNotNil: [ :model | 
	| nodes boundNodes bindings reps isolatedNodes |
	nodes :=  model nodes asSortedCollection: [ :node1 :node2 |
		         node2 id <= node1 id ].
	boundNodes := nodes reject: [ :node | node isIsolated ].
	divisions := (boundNodes size sqrt * 1.4) ceiling max: 1.
	softDivisions := divisions asFloat - 1.0e-8.
	self swirlLayout: boundNodes.
	bindings := self bindings.
	reps := 40000000 // (boundNodes size squared max: 1) min: 100 max: 20.
	model ifNotNil: [
		UIManager default
			displayProgress: 'layouting'
			from: 1
			to: reps
			during: [ :progress |
				1 to: reps do: [ :i |
					progress value: i.
					5 timesRepeat: [
						self
							centralize: boundNodes;
							bindParticles: boundNodes bindings: bindings;
							repulseParticles: boundNodes bindings: bindings;
							wall: boundNodes;
							adjustCenter: boundNodes ] ] ] ].
	self overridesYWithFrequency ifTrue: [
		| minY maxY minF maxF |
		minY := (boundNodes collect: #y thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #min.
		maxY := (boundNodes collect: #y thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #max.
		minF := (boundNodes collect: model nodeEvaluator thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #min.
		maxF := (boundNodes collect: model nodeEvaluator thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #max.
		(minY ~= maxY and: [ minF ~= maxF ]) ifTrue: [
			| offset scale |
			offset := minY.
			scale := maxY - minY / (maxF - minF).
			boundNodes do: [ :node |
				self
					move: node
					toY: maxF - (model valueAtNode: node) * scale + offset ] ] ].
	self overridesYWithFrequencyOrder ifTrue: [
		| minY maxY minF maxF |
		minY := (boundNodes collect: #y thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #min.
		maxY := (boundNodes collect: #y thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #max.
		minF := (boundNodes collect: model nodeEvaluator thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #min.
		maxF := (boundNodes collect: model nodeEvaluator thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #max.
		(minY ~= maxY and: [ minF ~= maxF and: [ boundNodes size > 1 ] ])
			ifTrue: [
				| offset scale |
				offset := minY.
				scale := maxY - minY / (boundNodes size - 1).
				(boundNodes asSortedCollection: [ :more :less |
					 | v1 v2 |
					 v1 := model valueAtNode: more.
					 v2 := model valueAtNode: less.
					 v2 isNil or: [ v1 notNil and: [ v1 >= v2 ] ] ]) doWithIndex: [
					:node
					:index |
					self move: node toY: (index - 1) asFloat * scale + offset ] ] ].
	((boundNodes collect: #x thenSelect: #notNil)
		 ifEmpty: [ 0.0 ]
		 ifNotEmpty: #min) floor
	@ ((boundNodes collect: #y thenSelect: #notNil)
			 ifEmpty: [ 0.0 ]
			 ifNotEmpty: #min) floor in: [ :offset |
		boundNodes do: [ :node |
			self move: node toX: node x - offset x y: node y - offset y ] ].
	divisions := (((boundNodes collect: #x)
		               ifEmpty: [ 0 ]
		               ifNotEmpty: #max) ceiling max:
		              ((boundNodes collect: #y)
			               ifEmpty: [ 0 ]
			               ifNotEmpty: #max) ceiling) + 1.
	isolatedNodes := (nodes select: #isIsolated) readStream.
	[
	divisions := divisions + (1 / 2).
	1 to: divisions by: 1 / 2 do: [ :x |
		isolatedNodes atEnd ifTrue: [
			divisions := divisions ceiling.
			^ self ].
		self move: isolatedNodes next toX: x - 0.25 y: divisions - 0.25 ].
	1 to: divisions - (1 / 2) by: 1 / 2 do: [ :y |
		isolatedNodes atEnd ifTrue: [
			divisions := divisions ceiling.
			^ self ].
		self move: isolatedNodes next toX: divisions - 0.25 y: y - 0.25 ] ]
		repeat]
]

{ #category : 'layouting' }
Golap2dSpringLayouter >> repulseParticles: aCollectionOfGolapNode bindings: bindings [

	| cells |
	cells := (1 to: divisions) collect: [ :i |
		         (1 to: divisions) collect: [ :j |
			         (OrderedCollection new:
				          (aCollectionOfGolapNode size // divisions squared + 10
					           max: 10)) -> (OrderedCollection new:
				          (aCollectionOfGolapNode size // divisions squared + 10
					           max: 10)) ] ].
	aCollectionOfGolapNode do: [ :v |
		| x y pair |
		x := v x ceiling min: divisions max: 1.
		y := v y ceiling min: divisions max: 1.
		pair := {
			        v asPoint.
			        v id }.
		((cells at: x) at: y) key add: v.
		((cells at: x) at: y) value add: pair.
		y >= 2 ifTrue: [ ((cells at: x) at: y - 1) value add: pair ].
		y < divisions ifTrue: [ ((cells at: x) at: y + 1) value add: pair ].
		x >= 2 ifTrue: [
			| c |
			c := cells at: x - 1.
			(c at: y) value add: pair.
			y >= 2 ifTrue: [ (c at: y - 1) value add: pair ].
			y < divisions ifTrue: [ (c at: y + 1) value add: pair ] ].
		x < divisions ifTrue: [
			| c |
			c := cells at: x + 1.
			(c at: y) value add: pair.
			y >= 2 ifTrue: [ (c at: y - 1) value add: pair ].
			y < divisions ifTrue: [ (c at: y + 1) value add: pair ] ] ].
	cells do: [ :cs |
		cs do: [ :pair |
			pair key do: [ :v1 |
				| v c p1 |
				v := 0.0.
				c := 0.
				p1 := v1 asPoint.
				pair value do: [ :v2pair |
					| p2 |
					p2 := v2pair first.
					p1 = p2 ifFalse: [
						| dx dy r |
						((dx := p1 x - p2 x) < 1.0 and: [
							 (dy := p1 y - p2 y) < 1.0 and: [
								 (r := (dx squared + dy squared) sqrt) < 0.5 ] ]) ifTrue: [
							c := c + 1.
							r > 1.0e-8
								ifTrue: [
								v := v
								     + (dx * (1.0 - r) * 0.1 / r @ (dy * (1.0 - r) * 0.1 / r)) ]
								ifFalse: [
									v1 id <= v2pair second
										ifTrue: [ v := v + 1.0e-4 asPoint ]
										ifFalse: [ v := v + -1.0e-4 asPoint ] ] ] ] ].
				c > 0 ifTrue: [
					self
						move: v1
						toX: (v1 x + (v x / c asFloat min: 1.0 max: -1.0)
								 min: softDivisions
								 max: 1.0e-8)
						y: (v1 y + (v y / c asFloat min: 1.0 max: -1.0)
								 min: softDivisions
								 max: 1.0e-8) ] ] ] ]
]

{ #category : 'layouting' }
Golap2dSpringLayouter >> swirlLayout: aCollectionOfGolapNode [

	| width |
	width := divisions // 2 * 2 + 1.
	aCollectionOfGolapNode doWithIndex: [ :node :i |
		| x y |
		x := i \\ width + 1.
		y := i // width + 1.
		self move: node toX: x - 0.5 y: y - 0.5 ]
]

{ #category : 'layouting' }
Golap2dSpringLayouter >> wall: aCollectionOfGolapNode [

	| min max |
	min := 0.0.
	max := divisions asFloat.
	aCollectionOfGolapNode do: [ :node |
		self
			move: node
			toX: (node x min: max max: min)
			y: (node y min: max max: min) ]
]
