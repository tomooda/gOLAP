Class {
	#name : 'GolapStoerWagnerCutter',
	#superclass : 'Object',
	#instVars : [
		'root',
		'mp'
	],
	#category : 'Golap-Models-Analysis',
	#package : 'Golap-Models',
	#tag : 'Analysis'
}

{ #category : 'examples' }
GolapStoerWagnerCutter class >> example [

	| n es result solver |
	n := 8.
	es := {
		      { 1. 2. 2 }.
		      { 2. 3. 3 }.
		      { 3. 4. 4 }.
		      { 1. 5. 3 }.
		      { 2. 5. 2 }.
		      { 2. 6. 2 }.
		      { 3. 7. 2 }.
		      { 4. 7. 2 }.
		      { 4. 8. 2 }.
		      { 5. 6. 3 }.
		      { 6. 7. 1 }.
		      { 7. 8. 3 } }.

	solver := self new.
	result := solver globalMinimumCut: es.
	self assert: (result collect: #third) sum = 4.
	result inspect
]

{ #category : 'initialization' }
GolapStoerWagnerCutter >> _globalMinimumCut: anArrayOfTriple [

	| n res g merged node0 dict0 |
	anArrayOfTriple ifEmpty: [ ^ nil ].
	g := IdentityDictionary new.
	anArrayOfTriple do: [ :edge |
			(g at: edge first ifAbsentPut: [ IdentityDictionary new ]) at: edge second put: edge third.
			(g at: edge second ifAbsentPut: [ IdentityDictionary new ]) at: edge first put: edge third ].
	n := g size.
	node0 := g keys anyOne.
	dict0 := g at: node0.
	res := Float infinity.
	merged := Set new: n.

	[ true ] whileTrue: [
			| done heap data order v ws u |
			done := Set new: n.
			done add: node0.
			data := OrderedCollection new.
			g keysDo: [ :node |
					((merged includes: node) not and: [ node ~= node0 ]) ifTrue: [
							| weight |
							weight := dict0 at: node ifAbsent: [ 0 ].
							data add: node -> weight negated ] ].
			heap := GolapBinaryHeapNode withAll: data.
			order := OrderedCollection new.
			[ heap isNil ] whileFalse: [
					| id |
					id := heap id.
					heap := heap pop.
					g at: id ifPresent: [ :d |
							d keysAndValuesDo: [ :n1 :w |
								(done includes: n1) ifFalse: [
									heap nodeAt: n1 ifPresent: [ :node | node updatePriorityWith: [ :priority | priority - w ] ] ] ] ].
					done add: id.
					order add: id ].

			v := [ order removeLast ]
				     on: CollectionIsEmpty
				     do: [ :ex | ^ res ].
			ws := 0.
			g at: v ifPresent: [ :d | d valuesDo: [ :w | ws := ws + w ] ].
			res := res min: ws.

			u := [ order removeLast ]
				     on: CollectionIsEmpty
				     do: [ :ex | ^ res ].

			merged add: v.
			g at: v ifPresent: [ :d |
					d keysAndValuesDo: [ :n1 :w |
							n1 ~= u ifTrue: [
									| gu gw |
									gu := g at: u.
									gw := g at: n1.
									(gu includesKey: n1)
										ifTrue: [
												gu at: n1 put: (gu at: n1) + w.
												gw at: u put: (gw at: u) + w ]
										ifFalse: [
												gu at: n1 put: w.
												gw at: u put: w ] ].
							(g at: n1) removeKey: v ifAbsent: [ ] ] ].
			g removeKey: v ifAbsent: [ ] ].
	^ res
]

{ #category : 'initialization' }
GolapStoerWagnerCutter >> bestClusterByGlobalMinimumCut: anArrayOfTriple [

	| n res g merged node0 dict0 clusters bestCluster |
	anArrayOfTriple ifEmpty: [ ^ Array new ].
	g := IdentityDictionary new.
	anArrayOfTriple do: [ :edge |
			(g at: edge first ifAbsentPut: [ IdentityDictionary new ]) at: edge second put: edge third.
			(g at: edge second ifAbsentPut: [ IdentityDictionary new ]) at: edge first put: edge third ].
	n := g size.
	node0 := g keys anyOne.
	dict0 := g at: node0.
	clusters := (g keys collect: [ :node | node -> (OrderedCollection with: node) ]) asDictionary.
	bestCluster := (clusters at: node0) asArray.
	res := Float infinity.
	merged := Set new: n.

	[
		| done heap data order v ws u |
		done := Set new: n.
		done add: node0.
		data := OrderedCollection new.
		g keysDo: [ :node |
				((merged includes: node) not and: [ node ~= node0 ]) ifTrue: [
						| weight |
						weight := dict0 at: node ifAbsent: [ 0 ].
						data add: node -> weight negated ] ].
		heap := GolapBinaryHeapNode withAll: data.
		order := OrderedCollection new.
		[ heap isNil ] whileFalse: [
				| id |
				id := heap id.
				heap := heap pop.
				g at: id ifPresent: [ :d |
						d keysAndValuesDo: [ :n1 :w |
							(done includes: n1) ifFalse: [
								heap nodeAt: n1 ifPresent: [ :node | node updatePriorityWith: [ :priority | priority - w ] ] ] ] ].
				done add: id.
				order add: id ].

		v := [ order removeLast ]
			     on: CollectionIsEmpty
			     do: [ :ex | ^ bestCluster ].
		ws := 0.
		g at: v ifPresent: [ :d | d valuesDo: [ :w | ws := ws + w ] ].
		ws < res ifTrue: [
				res := ws.
				bestCluster := (clusters at: v) asArray ].

		u := [ order removeLast ]
			     on: CollectionIsEmpty
			     do: [ :ex | ^ bestCluster ].

		merged add: v.
		(clusters at: u) addAll: (clusters at: v).
		g at: v ifPresent: [ :d |
				d keysAndValuesDo: [ :n1 :w |
						n1 ~= u ifTrue: [
								| gu gw |
								gu := g at: u.
								gw := g at: n1.
								(gu includesKey: n1)
									ifTrue: [
											gu at: n1 put: (gu at: n1) + w.
											gw at: u put: (gw at: u) + w ]
									ifFalse: [
											gu at: n1 put: w.
											gw at: u put: w ] ].
						(g at: n1) removeKey: v ifAbsent: [ ] ] ].
		g removeKey: v ifAbsent: [ ] ] repeat
]

{ #category : 'initialization' }
GolapStoerWagnerCutter >> globalMinimumCut: anArrayOfTriple [

	| cluster |
	cluster := (self bestClusterByGlobalMinimumCut: anArrayOfTriple) asSet.
	^ anArrayOfTriple select: [ :triple | (cluster includes: triple first) and: [ (cluster includes: triple second) not ] ]
]
