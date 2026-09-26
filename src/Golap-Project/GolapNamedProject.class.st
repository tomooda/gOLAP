Class {
	#name : 'GolapNamedProject',
	#superclass : 'GolapProject',
	#traits : 'TComparable',
	#classTraits : 'TComparable classTrait',
	#instVars : [
		'projectFile'
	],
	#category : 'Golap-Project',
	#package : 'Golap-Project'
}

{ #category : 'accessing' }
GolapNamedProject class >> all [

	^ self projectFiles collect: [ :ref | self on: ref ]
]

{ #category : 'instance creation' }
GolapNamedProject class >> named: aString [

	^ self new
		  projectName: aString;
		  yourself
]

{ #category : 'instance creation' }
GolapNamedProject class >> on: aFileReference [

	^ self new
		  projectFile: aFileReference;
		  yourself
]

{ #category : 'operations' }
GolapNamedProject class >> open [

	self current open
]

{ #category : 'accessing' }
GolapNamedProject class >> projectBaseDirectory [

	^ self golapDirectory
]

{ #category : 'operations' }
GolapNamedProject class >> save [

	self current save
]

{ #category : 'comparing' }
GolapNamedProject >> < aComparable [
	"Answer whether the receiver is less than the argument."

	^ self projectName < aComparable projectName
]

{ #category : 'comparing' }
GolapNamedProject >> = anObject [

	^ self class = anObject class and: [ self projectName = anObject projectName ]
]

{ #category : 'converting' }
GolapNamedProject >> asJSON [

	^ super asJSON
		  at: 'project' put: self projectName;
		  yourself
]

{ #category : 'testing' }
GolapNamedProject >> exists [

	^ projectFile notNil and: [ projectFile exists ]
]

{ #category : 'converting' }
GolapNamedProject >> fromJSON: aDictionaryOrNil [

	aDictionaryOrNil at: 'project' ifPresent: [ :projectName | self projectName: projectName ].
	super fromJSON: aDictionaryOrNil
]

{ #category : 'comparing' }
GolapNamedProject >> hash [

	^ self class hash bitXor: self projectName hash
]

{ #category : 'controlling' }
GolapNamedProject >> ifDefault: aBlock otherwise: anotherBlock [

	^ anotherBlock cull: self
]

{ #category : 'accessing' }
GolapNamedProject >> projectFile [

	^ projectFile
]

{ #category : 'accessing' }
GolapNamedProject >> projectFile: aFileReference [

	projectFile := aFileReference
]

{ #category : 'accessing' }
GolapNamedProject >> projectName [

	^ projectFile ifNotNil: [ projectFile basenameWithoutExtension: self class fileExtension ]
]

{ #category : 'accessing' }
GolapNamedProject >> projectName: aString [

	self projectFile: (self class projectBaseDirectory / aString withExtension: self class fileExtension)
]

{ #category : 'operations' }
GolapNamedProject >> renameTo: aString [

	self projectFile ifNotNil: [ :oldRef |
			self projectName: aString.
			self projectFile ifNotNil: [ :newRef | oldRef moveTo: newRef ] ]
]

{ #category : 'updating' }
GolapNamedProject >> updateMenubar [

	GolapMenubar reset
]
