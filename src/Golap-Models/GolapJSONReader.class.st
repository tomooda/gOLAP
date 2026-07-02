Class {
	#name : 'GolapJSONReader',
	#superclass : 'STONReader',
	#category : 'Golap-Models-JSON',
	#package : 'Golap-Models',
	#tag : 'JSON'
}

{ #category : 'parsing' }
GolapJSONReader >> parseNumber [

	| negated number |
	readStream peek = $N ifTrue: [ self match: 'NaN' do: [ ^ Float nan ] ].
	negated := readStream peekFor: $-.
	readStream peek = $I ifTrue: [
			self match: 'Infinity' do: [
					^ negated
						  ifTrue: [ Float infinity negated ]
						  ifFalse: [ Float infinity ] ] ].
	number := self parseNumberInteger.
	(readStream peekFor: $/)
		ifTrue: [
				number := Fraction
					          numerator: number
					          denominator: self parseNumberInteger.
				(readStream peekFor: $s) ifTrue: [
						number := ScaledDecimal
							          newFromNumber: number
							          scale: self parseNumberInteger ] ]
		ifFalse: [
				| isFloat |
				isFloat := false.
				(readStream peekFor: $.) ifTrue: [
						number := number + self parseNumberFraction.
						isFloat := true ].
				((readStream peekFor: $e) or: [ readStream peekFor: $E ]) ifTrue: [
					number := number * self parseNumberExponent ].
				isFloat ifTrue: [ number := number asFloat ] ].
	negated ifTrue: [ number := number negated ].
	self consumeWhitespace.
	^ number
]

{ #category : 'parsing' }
GolapJSONReader >> parseSimpleValue [

	readStream atEnd ifFalse: [
			readStream peek = $N ifTrue: [ ^ self parseNumber ].
			readStream peek = $I ifTrue: [ ^ self parseNumber ].
			self parseConstantDo: [ :value | ^ value ] ].
	^ super parseSimpleValue
]
