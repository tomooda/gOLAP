Class {
	#name : 'GolapDefaultProject',
	#superclass : 'GolapProject',
	#category : 'Golap-Project-Core',
	#package : 'Golap-Project',
	#tag : 'Core'
}

{ #category : 'testing' }
GolapDefaultProject >> exists [

	^ true
]

{ #category : 'controlling' }
GolapDefaultProject >> ifDefault: aBlock otherwise: anotherBlock [

	^ aBlock cull: self
]

{ #category : 'accessing' }
GolapDefaultProject >> projectFile [

	^ nil
]

{ #category : 'accessing' }
GolapDefaultProject >> projectName [

	^ nil
]
