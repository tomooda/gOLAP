Class {
	#name : #GolapLayouter,
	#superclass : #Object,
	#instVars : [
		'divisions',
		'model',
		'softDivisions',
		'overridesYWithFrequency',
		'overridesYWithFrequencyOrder'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #'instance creation' }
GolapLayouter class >> on: aGolapModel [
	^ self new
		model: aGolapModel;
		yourself
]

{ #category : #layouting }
GolapLayouter >> adjustCenter: aCollectionOfGolapVertex [
	| numVertices minX minY maxX maxY meanX meanY |
	numVertices := aCollectionOfGolapVertex size.
	minX := maxX := divisions asFloat * 0.5.
	minY := maxY := divisions asFloat * 0.5.
	aCollectionOfGolapVertex
		do: [ :vertex | 
			| x y |
			x := vertex x.
			y := vertex y.
			minX := minX min: x.
			maxX := maxX max: x.
			minY := minY min: y.
			maxY := maxY max: y ].
	meanX := 0.0.
	meanY := 0.0.
	aCollectionOfGolapVertex
		do: [ :vertex | 
			meanX := meanX + vertex x.
			meanY := meanY + vertex y ].
	meanX := divisions asFloat * 0.5
		- (meanX / (numVertices max: 1) asFloat).
	meanY := divisions asFloat * 0.5
		- (meanY / (numVertices max: 1) asFloat).
	aCollectionOfGolapVertex
		do: [ :vertex | 
			vertex
				x: vertex x + meanX;
				y: vertex y + meanY ]
]

{ #category : #layouting }
GolapLayouter >> bindParticles: aCollectionOfGolapVertex bindings: bindings [
	| velocities |
	velocities := IdentityDictionary new: aCollectionOfGolapVertex size.
	aCollectionOfGolapVertex
		do: [ :vertex | velocities at: vertex put: 0.0 @ 0.0 ].
	aCollectionOfGolapVertex
		do: [ :v1 | 
			| p1 |
			p1 := v1 asPoint.
			(bindings at: v1)
				do: [ :v2 | 
					| p2 v |
					p2 := v2 asPoint.
					v := p2 - p1.
					v r > 0.2
						ifTrue: [ velocities
								at: v1
								put: (velocities at: v1) + (p2 - (v normalized * 0.2) - p1) ] ] ].
	velocities
		keysAndValuesDo: [ :v :p | 
			| numBindings |
			numBindings := (bindings at: v) size asFloat.
			numBindings > 1.0e-8
				ifTrue: [ v
						x:
							(v x + (p x / (bindings at: v) size asFloat)
								min: softDivisions
								max: 1.0e-8);
						y:
							(v y + (p y / (bindings at: v) size asFloat)
								min: softDivisions
								max: 1.0e-8) ] ]
]

{ #category : #layouting }
GolapLayouter >> bindings [
	| bindings |
	bindings := IdentityDictionary new.
	model
		ifNotNil: [ model
				bindingEdgesDo: [ :edge | 
					| v1 v2 |
					v1 := edge vertex1.
					v2 := edge vertex2.
					v1 ~~ v2
						ifTrue: [ (bindings at: v1 ifAbsentPut: [ OrderedCollection new ]) add: v2.
							(bindings at: v2 ifAbsentPut: [ OrderedCollection new ])
								add: v1 ] ].
			model
				verticesDo: [ :v | bindings at: v ifAbsentPut: [ OrderedCollection new ] ] ].
	^ bindings
]

{ #category : #layouting }
GolapLayouter >> centralize: aCollectionOfGolapVertex [
	aCollectionOfGolapVertex
		do: [ :v | 
			v
				x: (v x - (divisions * 0.5)) * 0.99 + (divisions * 0.5);
				y: (v y - (divisions * 0.5)) * 0.99 + (divisions * 0.5) ]
]

{ #category : #accessing }
GolapLayouter >> divisions [
	^ divisions ifNil: [ 1 ]
]

{ #category : #initialization }
GolapLayouter >> initialize [

	super initialize.
	divisions := nil.
	overridesYWithFrequency := false.
	overridesYWithFrequencyOrder := false
]

{ #category : #layouting }
GolapLayouter >> layout [

	| vertices boundVertices bindings reps isolatedVertices |
	vertices := self model vertices asSortedCollection: [ :v1 :v2 |
		            v2 frequency < v1 frequency or: [ v2 id <= v1 id ] ].
	boundVertices := vertices reject: [ :vertex | vertex isIsolated ].
	divisions := (boundVertices size sqrt * 1.4) ceiling max: 1.
	softDivisions := divisions asFloat - 1.0e-8.
	self swirlLayout: boundVertices.
	bindings := self bindings.
	reps := 40000000 // (boundVertices size squared max: 1)
		        min: 100
		        max: 20.
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
							centralize: boundVertices;
							bindParticles: boundVertices bindings: bindings;
							repulseParticles: boundVertices bindings: bindings;
							wall: boundVertices;
							adjustCenter: boundVertices ] ] ] ].
	self overridesYWithFrequency ifTrue: [
		| minY maxY minF maxF |
		minY := (boundVertices collect: #y thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #min.
		maxY := (boundVertices collect: #y thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #max.
		minF := (boundVertices collect: #frequency thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #min.
		maxF := (boundVertices collect: #frequency thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #max.
		(minY ~= maxY and: [ minF ~= maxF ]) ifTrue: [
			| offset scale |
			offset := minY.
			scale := maxY - minY / (maxF - minF).
			boundVertices do: [ :vertex |
				vertex y: maxF - vertex frequency * scale + offset ] ] ].
	self overridesYWithFrequencyOrder ifTrue: [
		| minY maxY minF maxF |
		minY := (boundVertices collect: #y thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #min.
		maxY := (boundVertices collect: #y thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #max.
		minF := (boundVertices collect: #frequency thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #min.
		maxF := (boundVertices collect: #frequency thenSelect: #notNil)
			        ifEmpty: [ 0.0 ]
			        ifNotEmpty: #max.
		(minY ~= maxY and: [ minF ~= maxF and: [ boundVertices size > 1 ] ])
			ifTrue: [
				| offset scale |
				offset := minY.
				scale := maxY - minY / (boundVertices size - 1).
				(boundVertices asSortedCollection: [ :more :less |
					 less frequency isNil or: [
						 more frequency notNil and: [ more frequency >= less frequency ] ] ])
					doWithIndex: [ :vertex :index |
					vertex y: (index - 1) asFloat * scale + offset ] ] ].
	((boundVertices collect: #x thenSelect: #notNil)
		 ifEmpty: [ 0.0 ]
		 ifNotEmpty: #min) floor
	@ ((boundVertices collect: #y thenSelect: #notNil)
			 ifEmpty: [ 0.0 ]
			 ifNotEmpty: #min) floor in: [ :offset |
		boundVertices do: [ :v |
			v
				x: v x - offset x;
				y: v y - offset y ] ].
	divisions := (((boundVertices collect: #x)
		               ifEmpty: [ 0 ]
		               ifNotEmpty: #max) ceiling max:
		              ((boundVertices collect: #y)
			               ifEmpty: [ 0 ]
			               ifNotEmpty: #max) ceiling) + 1.
	isolatedVertices := (vertices select: [ :vertex | vertex isIsolated ])
		                    readStream.
	[
	divisions := divisions + (1 / 2).
	1 to: divisions by: 1 / 2 do: [ :x |
		isolatedVertices atEnd ifTrue: [
			divisions := divisions ceiling.
			^ self ].
		isolatedVertices next
			x: x - 0.25;
			y: divisions - 0.25 ].
	1 to: divisions - (1 / 2) by: 1 / 2 do: [ :y |
		isolatedVertices atEnd ifTrue: [
			divisions := divisions ceiling.
			^ self ].
		isolatedVertices next
			x: divisions - 0.25;
			y: y - 0.25 ] ] repeat
]

{ #category : #accessing }
GolapLayouter >> model [
	^ model
]

{ #category : #accessing }
GolapLayouter >> model: aGolapModel [
	model := aGolapModel
]

{ #category : #accessing }
GolapLayouter >> overridesYWithFrequency [
	^ overridesYWithFrequency = true
]

{ #category : #accessing }
GolapLayouter >> overridesYWithFrequency: aBoolean [
	overridesYWithFrequency := aBoolean = true
]

{ #category : #accessing }
GolapLayouter >> overridesYWithFrequencyOrder [
	^ overridesYWithFrequencyOrder = true
]

{ #category : #accessing }
GolapLayouter >> overridesYWithFrequencyOrder: aBoolean [
	overridesYWithFrequencyOrder := aBoolean = true
]

{ #category : #layouting }
GolapLayouter >> repulseParticles: aCollectionOfGolapVertex bindings: bindings [

	| cells |
	cells := (1 to: divisions) collect: [ :i |
		         (1 to: divisions) collect: [ :j |
			         (OrderedCollection new:
				          (aCollectionOfGolapVertex size // divisions squared + 10
					           max: 10)) -> (OrderedCollection new:
				          (aCollectionOfGolapVertex size // divisions squared + 10
					           max: 10)) ] ].
	aCollectionOfGolapVertex do: [ :v |
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
					v1
						x: (v1 x + (v x / c asFloat min: 1.0 max: -1.0)
								 min: softDivisions
								 max: 1.0e-8);
						y: (v1 y + (v y / c asFloat min: 1.0 max: -1.0)
								 min: softDivisions
								 max: 1.0e-8) ] ] ] ]
]

{ #category : #layouting }
GolapLayouter >> swirlLayout: aCollectionOfGolapVertex [
	| width |
	width := divisions // 2 * 2 + 1.
	aCollectionOfGolapVertex
		doWithIndex: [ :v :i | 
			| x y |
			x := i \\ width + 1.
			y := i // width + 1.
			v
				x: x - 0.5;
				y: y - 0.5 ]
]

{ #category : #layouting }
GolapLayouter >> wall: aCollectionOfGolapVertex [
	| min max |
	min := 0.0.
	max := divisions asFloat.
	aCollectionOfGolapVertex
		do: [ :v | 
			v
				x: (v x min: max max: min);
				y: (v y min: max max: min) ]
]
