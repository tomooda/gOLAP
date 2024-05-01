Extension { #name : 'SpMorphicTableAdapter' }

{ #category : '*Golap-UI' }
SpMorphicTableAdapter >> buildWidget [

	widget := SpFTTableMorph new
		          hResizing: #spaceFill;
		          vResizing: #spaceFill;
		          intercellSpacing: self class intercellSpacing;
		          borderColor: (self borderColor ifNil: [ Color gray ]);
		          borderWidth: (self borderWidth ifNil: [ 0 ]);
		          yourself.

	self addModelTo: widget.

	^ widget
]
