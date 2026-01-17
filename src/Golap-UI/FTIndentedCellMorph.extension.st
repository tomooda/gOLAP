Extension { #name : 'FTIndentedCellMorph' }

{ #category : '*Golap-UI' }
FTIndentedCellMorph >> drawSubmorphsOn: aCanvas [

	(self ownerThatIsA: GolapFTTableMorph)
		ifNotNil: [ :table |
				| offset oldBounds oldFullBounds |
				offset := table offsetByHorizontalScroll.
				oldBounds := bounds.
				oldFullBounds := fullBounds.
				bounds := bounds translateBy: offset negated.
				fullBounds := fullBounds translateBy: offset negated.
				aCanvas
					translateBy: table offsetByHorizontalScroll
					clippingTo: (self currentWorld bounds)
					during: [ :canvas | super drawSubmorphsOn: canvas ].
				bounds := oldBounds.
				fullBounds := oldFullBounds ]
		ifNil: [ super drawSubmorphsOn: aCanvas ]
]
