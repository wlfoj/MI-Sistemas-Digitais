#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <intelfpgaup/KEY.h>
#include <intelfpgaup/video.h>
#include <intelfpgaup/accel.h>


// ====================================================== BLOCO DE 'OBJETOS' ATRIBUTOS ====================================================== //
typedef struct {
    int screen_x, screen_y;
    int char_x, char_y;
} Tela;

typedef struct {
    int pos_x;
    int pos_y;
    int dir; //Não sei o que seria isso, então vou criar o vel embaixo (att: Vanderleicio)
             // Era o ângulo da bola, seria mais fácil ter implementado com o ângulo (att: Washington)
    int vel[2];
    unsigned color;
} Bola;

typedef struct {
    // (pos_x1, pos_y1)
    int pos_x1;    // Ponto superior esquerdo
    int pos_y1;    // Ponto superior esquerdo

    // (pos_x2, pos_y2)
    int pos_x2;    // Ponto inferior direito
    int pos_y2;    // Ponto inferior direito

    //
    int existe;
    unsigned color;
} Bloco;

typedef struct {
    int pos_x1;    // Extremidade esquerda da barra
    int pos_x2;    // Extremidade direita da barra
    int width;     // Comprimento da barra (embora possa ser obtido com um simples x2-x1)
    int pos_y;     // Posição em Y onde a barra vai estar (é um valor inalterável)
    unsigned color;// 0xFFE0;
} Barra;


// ====================================== BLOCO DE FUNÇÕES PARA AS CONFIGURAÇÕES INICIAIS ==========================================//
/* Constrói as bordas da tela
    Param:
        - tela -> objeto que representa os tamanhos da tela
        - color -> cor a ser usada para fazer as linhas das bordas
*/
void build_cage(Tela *tela, unsigned color){
    //linha horizontal em cima de (0,0) para (319,0)
	video_line(0, 0, (*tela).screen_x - 1, 0, color);
	//fazer linha lateral esquerda de (0,0) para (0,239)
	video_line(0,0, 0, (*tela).screen_y - 1, color);
	// fazer linha lateral direita de (319,0) para (319, 239)
	video_line((*tela).screen_x - 1, 0, (*tela).screen_x - 1, (*tela).screen_y - 1, color);
	//
	//video_show();
}


// ========================================================== BLOCO DE FUNÇÕES PARA A BARRA ==========================================//
/* Apaga pinta de preto a posição da barra passada
    Param:
        - pos_x1 -> Posição da extremidade esquerda da barra
        - pos_x2 -> Posição da extremidade direita da barra
  
*/
//void erase_pos_Barra_previous(int pos_x1, int pos_x2){
//    video_line(pos_x1, 235, pos_x2, 235, 0);
//}


/* Atualiza a posição da barra, no buffer, com base na leitura de acelerômetro
    Param:
        - barra -> Objeto Barra
        - tela -> Objeto Tela
*/
void update_pos_Barra(Barra *barra, Tela *tela){
    int ac_ready, ac_tap, ac_dtap, x_val, y_val, z_val, mgper;

    accel_read(&ac_ready, &ac_tap, &ac_dtap, &x_val, &y_val, &z_val, &mgper);
    // Faz a calibragem para reduzir o valor e utilizar diretamente como movimento da barra
	x_val = x_val/12;

    // ++++++++ Trecho de código para fazer a saturação e não deixar a bola passar das extremidades ++++++++ //
	if ((*barra).pos_x2 + x_val >= (*tela).screen_x - 2){ // Para a bola não passar do lado direito da tela
		(*barra).pos_x2 = (*tela).screen_x - 2;
		(*barra).pos_x1 = ((*tela).screen_x - 2) - ((*barra).width);// 
	}
	else if ((*barra).pos_x1 + x_val <= 2){ // Para a bola não passa do lado esquerdo da tela
		(*barra).pos_x1 = 2;
		(*barra).pos_x2 = (*barra).pos_x1 + (*barra).width;
	}
	else{// Estando dentro do intervalo de x permitido para locomoção
		(*barra).pos_x1 = (*barra).pos_x1 + x_val;
		(*barra).pos_x2 = (*barra).pos_x2 + x_val;
	}
    // Escreve no buffer a nova posição da barra
    video_line((*barra).pos_x1, (*barra).pos_y, (*barra).pos_x2, (*barra).pos_y, (*barra).color);
}


// -------- --------- -------- QUE TIPO DE MONSTRUOSIDADE É ESTA? -------- --------- -------- //
void acelBolaBarra(Barra *bar, Bola *ball) {
    int lado = ((*bar).width/2) - 2;
    
      
    
    // para ball.pos_X = 1 e bar.pos_X1 = 1 Entre 1 e 18
    if (((*ball).pos_x >= (*bar).pos_x1) && ((*ball).pos_x <= (*bar).pos_x1 + lado)){
        (*ball).vel[0] = -1;
        (*ball).vel[1] = -1;
    } else if (((*ball).pos_x >= (*bar).pos_x1 + lado+1) && ((*ball).pos_x <= (*bar).pos_x1 + lado + 4)){ // entre 19 e 23
        (*ball).vel[0] = 0;
        (*ball).vel[1] = -1;
    } else if (((*ball).pos_x >= (*bar).pos_x1 + lado + 5) && ((*ball).pos_x <= (*bar).pos_x2)){ // entre 23 e 39
        (*ball).vel[0] = 1;
        (*ball).vel[1] = -1;					
    } else {
    	char msg[50];
    	sprintf(msg, "X: %d", (*ball).pos_x);
    	video_text (0, 0,msg); // Adicionado agora 
    }
}

// -------- --------- -------- QUE TIPO DE MONSTRUOSIDADE É ESTA? -------- --------- -------- //
void acelBolaBloco(Bloco *brick, Bola *ball) {
     if (((*ball).pos_y) == (*brick).pos_y2){
        //Batida inferior
        (*ball).vel[1] = 1; 
        //(*brick).existe = 0;
    } else if(((*ball).pos_y + 1) == (*brick).pos_y1){
        //Batida superior
        (*ball).vel[1] = -1;
        //(*brick).existe = 0;
    }
    
    else if((*ball).pos_x == (*brick).pos_x2){
        //Batida na direita
        (*ball).vel[0] = 1;
        //(*brick).existe = 0;
    }else if(((*ball).pos_x + 1) == (*brick).pos_x1){
		//Batida na esquerda
	//(*brick).existe = 0;
        (*ball).vel[0] = -1;
    } else{
    	printf("Desconhecido");
    }
}

update_pos_Bola(Bola *bola){
    (*bola).pos_x = (*bola).pos_x + (*bola).vel[0];
    (*bola).pos_y = ((*bola).pos_y + (*bola).vel[1]);
    // Escreve no buffer
    video_box((*bola).pos_x, (*bola).pos_y, ((*bola).pos_x + 1), ((*bola).pos_y + 1), (*bola).color);
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int main(){
	int botao_valor;// Utiliizado para descobrir o botão pressionado
	// int control = 1;// Permanece jogando
    Tela tela;//Ok
    Bola bola;
    Barra barra;//Ok
    int blocos_destruidos;
    int numBlocos = 40;// 10 blocos por linha e 4 linhas 
    int comprimento = 30; //Tamanho X do bloco
    int altura = 10; //Tamanho Y do bloco
    Bloco vetor[numBlocos];

    unsigned int video_color[] = {video_WHITE, video_YELLOW, video_RED,
    video_GREEN, video_BLUE, video_CYAN, video_MAGENTA, video_GREY,
    video_PINK, video_ORANGE};
    
    // Inicializando os devices
	if (!KEY_open ( ) || !video_open ( ) || !accel_open()){
	    return -1;
    }

    // Obtendo params da tela
    video_read(&tela.screen_x, &tela.screen_y, &tela.char_x, &tela.char_y);
    // Limpo qualquer coisa que possa ter na tela
    video_erase();
    video_clear ( );
    video_show ( ); 
    video_clear ( );

    // Inicializando o Acelerômetro
    accel_init();
    accel_calibrate();
    accel_format(1, 8);

    // Colocando os objetos nas posições iniciais
    build_cage(&tela, video_color[1]);// Constrói a gaiola

    // =========== Constrói a barra
    barra.width = 40;
    barra.pos_y = 235;
    barra.color = video_color[1];
    barra.pos_x1 = ((tela.screen_x -2)/2) - (barra.width/2);
    barra.pos_x2 = barra.pos_x1 + barra.width - 1;

    // =========== Constrói a bola
    bola.color = video_color[1];
    bola.dir = 270;
    // Se tivesse usado o bola.dir, os vetores de velocidade seriam vy = sen(dir) e vx = cos(dir)    (att: Washington)
    bola.vel[0] = 0;
    bola.vel[1] = 1;
    bola.pos_x = 160;
    bola.pos_y =  tela.screen_y - 100;
    
    // =========== Constrói os blocos
    int cont = 1;
    vetor[0].pos_x1 = 1;
    vetor[0].pos_y1 = 1;
    vetor[0].pos_x2 = 31;
    vetor[0].pos_y2 = 11;
    vetor[0].existe = 1;
    vetor[0].color = video_color[1];
    
    int i=1;
    for (i = 1; i < numBlocos; i++){
    	
        vetor[i].pos_x1 = vetor[i-1].pos_x2 + 2;
        vetor[i].pos_y1 = vetor[i-1].pos_y1;
        vetor[i].pos_x2 = vetor[i].pos_x1 + comprimento;
        vetor[i].pos_y2 = vetor[i].pos_y1 + altura;
        vetor[i].existe = 1;
        vetor[i].color = video_color[1];
        
        cont++;
        
        if (cont == 11){
         	cont = 1;
         	vetor[i].pos_x1 = vetor[0].pos_x1;
         	vetor[i].pos_y1 = vetor[i - 10].pos_y2 + 3;
			vetor[i].pos_y2 = vetor[i].pos_y1 + altura;
			vetor[i].pos_x2 = vetor[i].pos_x1 + comprimento;
        	vetor[i].existe = 1;
        	vetor[i].color = video_color[1];
         }
         
    }

    // ::::: ??????????????????? :::::MUDAR PARA CALCULOS ENVOLVENDO O TELA. //
    //int limite_x1= 1; //Pra bola não entrar na linha
    //int limite_y1= 1;
    //int limite_x2= tela.screen_x - 2;// 318
    //int limite_y2= tela.screen_y - 2;// 238
    // ::::: ??????????????????? ::::: //

	/// Deixa o jogo travado no inicio até que pressione o botão da esquerda
	KEY_read (&botao_valor);
	video_text (tela.char_x/2, tela.char_y/2, "Pressione o botao Iniciar");
	while(botao_valor != 8){// Só inicia o loop principal quando pressiona o botão 
		KEY_read (&botao_valor);
	}
	video_erase();
    blocos_destruidos = 0;
    // Loop principal do jogo
    while (1){
        // Veriifico se pressionou o botão de pausar
    	KEY_read (&botao_valor);
    	if(botao_valor == 4){// Fico no loop até que pressione o CONTINUAR
			video_text (tela.char_x/2, tela.char_y/2, "PAUSADO");
			while(botao_valor != 2){// Enquanto não apertar o botão continuar, fico no loop
				KEY_read (&botao_valor);
			}
			video_erase();
		}

    	video_clear();
        build_cage(&tela, video_color[1]);
    	
    	// --- --- Realiza as movimentações necessárias --- --- //
        update_pos_Bola(&bola);
	update_pos_Barra(&barra, &tela);
	
        // --- --- Verifico se a bola chocou com a gaiola ou perdeu  --- --- //
        if (bola.pos_x <= 1){// Pq considero a espessura da gaiola
            bola.vel[0] = 1;
        } else if((bola.pos_x + 1) >= tela.screen_x - 2){
            bola.vel[0] = -1;
        } else if((bola.pos_y) <= 1){ // Pq considero a espessura da gaiola
            bola.vel[1] = 1;
        } else if((bola.pos_y + 1) >= tela.screen_y - 2){
	    	// --- --- TELA DE FIM DE JOGO E REINICIAR --- --- //
			video_text (tela.char_x/3 - 6, tela.char_y/2 - 4, "FIM DE JOGO");
			video_text (tela.char_x/3 - 6, tela.char_y/2, "Pressione o botao Iniciar para reiniciar");
			KEY_read (&botao_valor);
			while(botao_valor != 8){// Só inicia o loop principal quando pressiona o botão 
				KEY_read (&botao_valor);
			}
			video_erase();

            // ==== Processo de reconstruir a tela, e disponibilizar para jogar novamente ==== //
			// Limpo qualquer coisa que possa ter na tela
			video_erase();
			video_clear ( ); // clear current VGA Back buffer
			video_show ( ); // swap Front/Back to display the cleared buffer
			video_clear ( ); // clear the VGA Back buffer, where we will draw lines

			// Inicializando o Acelerômetro
			accel_open();
			accel_init ();
			accel_calibrate ();
			accel_format (1, 8);

			// Colocando os objetos nas posições iniciais
			build_cage(&tela, video_color[1]);// Constrói a gaiola
			// =========== Constrói a barra
			barra.width = 40;
			barra.pos_y = 235;
			barra.color = video_color[1];
			barra.pos_x1 = ((tela.screen_x -2)/2) - (barra.width/2);
			barra.pos_x2 = barra.pos_x1 + barra.width - 1;
			// =========== Constrói a bola
			bola.color = video_color[1];
			bola.dir = 12;
			bola.vel[0] = 0;
			bola.vel[1] = 1;
			bola.pos_x = 160;//rand() % (tela.screen_x-2);// Gera a bola em uma posição aleatória no eixo x
			bola.pos_y =  tela.screen_y - 100;// Posição fixa em y 
			
			
            // Gerando os blocos nas posições iniciais
			cont = 1;
			vetor[0].pos_x1 = 1;
			vetor[0].pos_y1 = 1;
			vetor[0].pos_x2 = 31;
			vetor[0].pos_y2 = 11;
			vetor[0].existe = 1;
			vetor[0].color = video_color[1];
			
			i=1;
			for (i = 1; i < numBlocos; i++){
				
				vetor[i].pos_x1 = vetor[i-1].pos_x2 + 2;
				vetor[i].pos_y1 = vetor[i-1].pos_y1;
				vetor[i].pos_x2 = vetor[i].pos_x1 + comprimento;
				vetor[i].pos_y2 = vetor[i].pos_y1 + altura;
				vetor[i].existe = 1;
				vetor[i].color = video_color[1];
				
				cont++;
				
				if (cont == 11){
				 	cont = 1;
				 	vetor[i].pos_x1 = vetor[0].pos_x1;
				 	vetor[i].pos_y1 = vetor[i - 10].pos_y2 + 3;
					vetor[i].pos_y2 = vetor[i].pos_y1 + altura;
					vetor[i].pos_x2 = vetor[i].pos_x1 + comprimento;
					vetor[i].existe = 1;
					vetor[i].color = video_color[1];
				 }
				 
			}
			blocos_destruidos = 0;
        }
        ///===========================================================================================
	
        // Trecho que escreve os blocos
        for (i = 0; i < numBlocos; i++){
            //printf("Bloco: %i, X1:%i, Y1:%i, X2:%i, Y2:%i \n", i, vetor[i].pos_x1, vetor[i].pos_y1, vetor[i].pos_x2, vetor[i].pos_y2);
            if(vetor[i].existe){
		// O PROBLEMA ESTÁ AQUI !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
                if (((bola.pos_x >= (vetor[i].pos_x1) && bola.pos_x <= (vetor[i].pos_x2)) && 
                (bola.pos_y >= (vetor[i].pos_y1) && bola.pos_y <= (vetor[i].pos_y2))) || 
                (((bola.pos_x + 1) >= (vetor[i].pos_x1) && (bola.pos_x+1) <= (vetor[i].pos_x2)) && 
                ((bola.pos_y + 1) >= (vetor[i].pos_y1) && (bola.pos_y+1) <= (vetor[i].pos_y2))) ){
                    //Houve colisão com o bloco
                    blocos_destruidos = blocos_destruidos + 1;
                    vetor[i].existe = 0; //Bloco deixa de existir
                    acelBolaBloco(&vetor[i], &bola); //Bola muda de direção
                }
                video_box(vetor[i].pos_x1,vetor[i].pos_y1,vetor[i].pos_x2,vetor[i].pos_y2,vetor[i].color);
            }
        }
        
        if (blocos_destruidos == numBlocos){
        	video_text (tela.char_x/2, tela.char_y/2, "Venceu o jogo!!");
        	break;
        }
	
	// Verifico colisão com a barra
        if (bola.pos_x >= barra.pos_x1 && bola.pos_x <= barra.pos_x2 && (bola.pos_y+1) == barra.pos_y){
            acelBolaBarra(&barra, &bola);
            printf("%i",bola.pos_y +1);
        }

        video_show();
    }

    return 0;
}
