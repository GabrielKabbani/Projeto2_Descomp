

def print_piece(number):

    text = f"""BIT{str(number).zfill(2)} : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA({number}), B => entradaB({number}),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT({number - 1}), C_out => C_OUT({number}),
			S => saida({number})
		);"""
    
    print(text)

if __name__ == "__main__":
    for i in range(1, 31):
        print_piece(i)
        print()