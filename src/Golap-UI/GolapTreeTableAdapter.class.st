Class {
	#name : 'GolapTreeTableAdapter',
	#superclass : 'SpMorphicTreeTableAdapter',
	#category : 'Golap-UI-Spec',
	#package : 'Golap-UI',
	#tag : 'Spec'
}

{ #category : 'factory' }
GolapTreeTableAdapter >> buildWidget [

	| tableMorph |
	tableMorph := GolapFTTableMorph newWithHorizontalScrollBar
		              hResizing: #spaceFill;
		              vResizing: #spaceFill;
		              intercellSpacing: self class intercellSpacing;
		              dragEnabled: self dragEnabled;
		              dropEnabled: self dropEnabled;
		              yourself.

	self addModelTo: tableMorph.
	widget := tableMorph.
	self configureScrolling.

	^ tableMorph
]
