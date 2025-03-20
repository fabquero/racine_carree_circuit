library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity racinecarree is
    generic(n_bits: natural := 16);
	port(
		clk  : in std_logic;
		rst  : in std_logic;
		write: in std_logic;
        read : in std_logic;
        waitrequest: out std_logic;
		writedata : in std_logic_vector(2 * n_bits - 1 downto 0);
		readdata: out std_logic_vector(2 * n_bits -1 downto 0)
	);
end entity;

architecture arch of racinecarree is
    -- pour gerer les etats de notre machine a etat, ainsi on peut savoir ou on en est dans le calcul, et refaire le calcul.
    type state_t is (IDLE, COMP, WAIT_RES, END_COMP);
    signal state: state_t;

    -- resultat de la racine carree
    signal Z: unsigned(    n_bits - 1 downto 0);
    -- sauvegarde de la valeur d'entree
    signal D: unsigned(2 * n_bits - 1 downto 0);

    begin
        comport : process(write,writedata,rst,clk)

        -- on est oblige d'avoir R en tant que variable car on le teste tout de suite apres modification: on ne peut pas le faire avec un signal, on ne peut pas attendre un rising_edge.
        variable R: signed(2 * n_bits - 1 downto 0);
        -- compteur pour savoir ou on en est dans le calcul
        -- j'ai enleve le clog2(n_bits)-1 car on doit aller jusqu'a n. Quand ca fonctionnera on pourra le mettre a juste clog(n_bits): ps, la construction range 0 to n_bits est equivalente a clog2(n_bits)-1.
        variable i_step: integer range 0 to n_bits := 0;

        begin
            if rst = '1' then
                i_step := 0;
                waitrequest <= '0';
                readdata <= (others => '0');
            elsif rising_edge(clk) then --and i_step < n_bits then
                case state is
                    when IDLE =>
                        Z <= (others => '0');
                        R := (others => '0');
                        if write = '1' then
                            state <= COMP;
                            i_step := 0;
                            -- sauvegarde de la valeur d'entree
                            D <= unsigned(writedata);
                            waitrequest <= '1';
                        end if;
                    when COMP =>
                            -- calcul de la racine carree
                            if R >= to_signed(0, 2 * n_bits) then
                                R := (R sll 2) + ('0'&signed(std_logic_vector(D(2*n_bits - 1 downto 2*n_bits-2)))) - signed(std_logic_vector((Z sll 2))) - to_signed(1, 2 * n_bits);
                            else
                                R := (R sll 2) + ('0'&signed(std_logic_vector(D(2*n_bits - 1 downto 2*n_bits-2)))) + signed(std_logic_vector(Z sll 2)) + to_signed(3, 2 * n_bits);
                            end if;
                            if R >= to_signed(0, 2 * n_bits) then
                                -- car unsigned implemente l'addition. On pourrait faire la meme chose avec signed mais pour les expliquations, on va le faire avec la fonction to_signed.
                                Z <= (Z sll 1) + 1;
                            else
                                Z <= (Z sll 1);
                            end if;
                            D <= D sll 2;
                            -- avant je faisais une soustraction entre deux unsigned... ca n'a pas de sens.
                            i_step := i_step + 1;
                            if i_step = n_bits then
                                state <= WAIT_RES;
                            end if;
                    when WAIT_RES =>
                        readdata <=  (2 * n_bits - 1 downto n_bits => '0') & std_logic_vector(Z);
                        state <= END_COMP;
                    when END_COMP =>
                            waitrequest <= '0';
                            if read = '1' then
                                state <= IDLE;
                            end if;
                end case;
            end if;
        end process comport;

end architecture arch;

-- Liste des problèmes rencontrés:
-- Mauvais utilisation de l'algorithme, erreur: transforme le >= 0 par = 0 et le + 4*Z+3 par -4*Z+3
-- mauvaise utilisation des types
-- oublie de concatenation du bits 0 lors du passage en signed pour R
-- oublie de R en variable
