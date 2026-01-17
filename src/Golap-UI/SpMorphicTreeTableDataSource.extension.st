Extension { #name : 'SpMorphicTreeTableDataSource' }

{ #category : '*Golap-UI' }
SpMorphicTreeTableDataSource >> newHeaderColumn: column [

	| headerMorph |
	headerMorph := SpHeaderCellMorph new
		               addMorph:
			               (column id ifNil: [ '' ]) asMorph asReadOnlyMorph;
		               yourself.

	column isSortEnabled ifTrue: [
			headerMorph eventHandler: (MorphicEventHandler new
					 on: #click
					 send: #sortByColumn:event:morph:
					 to: self
					 withValue: column).
			column sortingIcon ifNotNil: [ :icon | headerMorph addMorph: icon ] ].

	^ headerMorph
]
