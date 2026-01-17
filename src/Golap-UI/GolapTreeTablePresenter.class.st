Class {
	#name : 'GolapTreeTablePresenter',
	#superclass : 'SpTreeTablePresenter',
	#category : 'Golap-UI-Spec',
	#package : 'Golap-UI',
	#tag : 'Spec'
}

{ #category : 'specs' }
GolapTreeTablePresenter class >> adapterName [

	^ #GolapTreeTableAdapter
]

{ #category : 'private' }
GolapTreeTablePresenter >> contentWidth: aNumber [

	self withAdapterDo: [ :a |
		a widgetDo: [ :w | w contentWidth: aNumber ] ]
]
