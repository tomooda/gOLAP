Class {
	#name : 'GolapMicrodownPresenter',
	#superclass : 'MicrodownPresenter',
	#category : 'Golap-Notepad-Microdown',
	#package : 'Golap-Notepad',
	#tag : 'Microdown'
}

{ #category : 'specs' }
GolapMicrodownPresenter class >> adapterName [

	^ #GolapMorphicMicrodownAdapter
]

{ #category : 'defaults' }
GolapMicrodownPresenter >> defaultTextStyler [

	^ GolapMicTextStyler new
]

{ #category : 'initialization' }
GolapMicrodownPresenter >> initialize [

	super initialize.
	self textStyler: self defaultTextStyler
]

{ #category : 'initialization' }
GolapMicrodownPresenter >> recompose [

	self withAdapterDo: [ :microdownAdapter | microdownAdapter recompose ]
]

{ #category : 'api - events' }
GolapMicrodownPresenter >> whenColorChangedDo: aBlock [

	self property: #color whenChangedDo: aBlock
]
