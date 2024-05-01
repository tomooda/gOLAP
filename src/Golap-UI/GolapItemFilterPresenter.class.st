Class {
	#name : 'GolapItemFilterPresenter',
	#superclass : 'GolapFilterPresenter',
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'accessing' }
GolapItemFilterPresenter >> filterSpec [
	^ self query itemFilterSpec
]
