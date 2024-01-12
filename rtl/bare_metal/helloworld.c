#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xaxidma.h"
#include "xil_io.h"
#include "xil_types.h"
#include "xil_exception.h"
#include "xscugic.h"
#include "xil_cache.h"
#include "sleep.h"
#include "xdebug.h"
#include "title_parametars.h"


#define DMA_DEV_ID    XPAR_AXIDMA_0_DEVICE_ID     // DMA Device ID
#define DMA_BASEADDR  XPAR_AXI_DMA_0_BASEADDR     // DMA BaseAddr
#define DDR_BASE_ADDR   XPAR_PS7_DDR_0_S_AXI_BASEADDR // DDR START ADDRESS
#define MEM_BASE_ADDR (DDR_BASE_ADDR + 0x1000000)   // MEM START ADDRESS

//TITLE_IP parametars
#define TITLE_DEV_ID XPAR_TITLE_IP_0_DEVICE_ID
#define TITLE_BASEADDR XPAR_TITLE_IP_0_S00_AXI_BASEADDR

// REGISTER OFFSETS FOR DMA
// MEMORY TO STREAM REGISTER OFFSETS
#define MM2S_DMACR_OFFSET 0x00
#define MM2S_DMASR_OFFSET   0x04
#define MM2S_SA_OFFSET    0x18
#define MM2S_SA_MSB_OFFSET  0x1c
#define MM2S_LENGTH_OFFSET  0x28
// STREAM TO MEMORY REGISTER OFFSETS
#define S2MM_DMACR_OFFSET 0x30
#define S2MM_DMASR_OFFSET   0x34
#define S2MM_DA_OFFSET    0x48
#define S2MM_DA_MSB_OFFSET  0x4c
#define S2MM_LENGTH_OFFSET  0x58

// FLAG BITS INSIDE DMACR REGISTER
#define DMACR_IOC_IRQ_EN  (1 << 12) // this is IOC_IrqEn bit in DMACR register
#define DMACR_ERR_IRQ_EN  (1 << 14) // this is Err_IrqEn bit in DMACR register
#define DMACR_RESET     (1 << 2)  // this is Reset bit in DMACR register
#define DMACR_RS       1      // this is RS bit in DMACR register

#define DMASR_IOC_IRQ     (1 << 12) // this is IOC_Irq bit in DMASR register

// TRANSMIT TRANSFER (MEMORY TO STREAM) INTERRUPT ID
#define TX_INTR_ID    XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR
// TRANSMIT TRANSFER (MEMORY TO STREAM) BUFFER START ADDRESS
#define TX_BUFFER_BASE  (MEM_BASE_ADDR + 0x00001000)

// RECIEVE TRANSFER (STREAM TO MEMORY) INTERRUPT ID
#define RX_INTR_ID    XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR
// RECIEVE TRANSFER (STREAM TO MEMORY) BUFFER START ADDRESS
#define RX_BUFFER_BASE  (MEM_BASE_ADDR + 0x00010000)

//TITLE INTERUPTS
#define INTERUPT_END_COMMAND_ID XPAR_FABRIC_TITLE_IP_0_END_COMMAND_INTERRUPT_INTR
#define INTERUPT_FRAME_FINISHED_ID XPAR_FABRIC_TITLE_IP_0_FRAME_FINISHED_INTERRUPT_INTR

// INTERRUPT CONTROLLER DEVICE ID
#define INTC_DEVICE_ID  XPAR_PS7_SCUGIC_0_DEVICE_ID

//WTF IS THIS
#define RESET_TIMEOUT_COUNTER 10000

// AMOUNT OF BYTES IN A TRANSFER
#define XFER_LENGTH 128*4

//COMMANDS FOR TITLE IP
#define LOAD_LETTER_DATA 0x00000001
#define LOAD_LETTER_MATRIX 0x00000002
#define LOAD_TEXT 0x00000004
#define LOAD_POSSITION 0x00000008
#define LOAD_PHOTO 0x00000010
#define PROCESSING 0x00000020
#define SEND_FROM_BRAM 0x00000040
#define RESET 0x00000080

#define AXI_OFFSET 0x4

#define IMAGE_1_ROW 101
#define IMAGE_1_WIDTH 640

//System functions, define whole system
static void Disable_Interrupt_System();
static void End_Command_Interrupt_Handler(void *Callback);
static void Frame_Finished_Interrupt_Handler(void *Callback);
u32 Setup_Interrupt(u32 DeviceId, Xil_InterruptHandler Handler, u32 interrupt_ID);
void DMA_init_interrupts();

void load_int_in_tx_buffer(int* int_array, u16* u16_array, int num_of_parametars);
void load_photo_in_tx_buffer(int* photo, u16* array, int start, int number);
XScuGic_Config *IntcConfig;
static XScuGic INTCInst;

XAxiDma_Config *myDmaConfig;
XAxiDma myDma;

u16 TxBuffer[195000];
u16 RxBuffer[195000];

volatile int end_command_done = 0;
volatile int frame_finished_done = 0;


int main()
{
	int miss = 0;
	int part_of_photo = 1;
	int start_tmp;

	Xil_DCacheDisable();
	Xil_ICacheDisable();
	init_platform();
	u32 status;
	myDmaConfig = XAxiDma_LookupConfigBaseAddr(DMA_BASEADDR);
	status = XAxiDma_CfgInitialize(&myDma, myDmaConfig);
	if(status != XST_SUCCESS){
		print("DMA initialization failed\n");
		return -1;
	}

	Xil_DCacheFlushRange((u32)TxBuffer,195000*sizeof(u16));
	Xil_DCacheFlushRange((u32)RxBuffer,195000*sizeof(u16));
	status=Setup_Interrupt(INTC_DEVICE_ID, (Xil_InterruptHandler)End_Command_Interrupt_Handler, INTERUPT_END_COMMAND_ID);
	if(status != XST_SUCCESS){
		print("Interupt initialization failed\n");
	    return -1;
	}

	status=Setup_Interrupt(INTC_DEVICE_ID, (Xil_InterruptHandler)Frame_Finished_Interrupt_Handler, INTERUPT_FRAME_FINISHED_ID);
	if(status != XST_SUCCESS){
		print("Interupt initialization failed\n");
		return -1;
	}

	DMA_init_interrupts();

	//RESET IP
	Xil_Out32(TITLE_BASEADDR ,  (UINTPTR)RESET);

	//LOAD LETTERDATA
	end_command_done = 0;
	load_int_in_tx_buffer(letterData, TxBuffer, 214);
	Xil_Out32(TITLE_BASEADDR ,  (UINTPTR)LOAD_LETTER_DATA);
	status = XAxiDma_SimpleTransfer(&myDma, (u32)TxBuffer, 214*sizeof(u16),XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS){
		xil_printf("Greska u slanju transakcije\r\n");
	}

	while(!end_command_done);
	end_command_done = 0;

	//LOAD LETTERMATRIX
	load_int_in_tx_buffer(letterMatrix, TxBuffer, 16602);
	Xil_Out32(TITLE_BASEADDR ,  (UINTPTR)LOAD_LETTER_MATRIX);
	status = XAxiDma_SimpleTransfer(&myDma, (u32)TxBuffer, 16602*sizeof(u16),XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS){
		xil_printf("Greska u slanju transakcije\r\n");
	}

	while(!end_command_done);
	end_command_done = 0;

	//LOAD POSSITION
	load_int_in_tx_buffer(possition, TxBuffer, 106);
	Xil_Out32(TITLE_BASEADDR ,  (UINTPTR)LOAD_POSSITION);
	status = XAxiDma_SimpleTransfer(&myDma, (u32)TxBuffer, 106*sizeof(u16),XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS){
		xil_printf("Greska u slanju transakcije\r\n");
	}

	while(!end_command_done);
	end_command_done = 0;

	//LOAD TEXT
	load_int_in_tx_buffer(text, TxBuffer, 55);
	Xil_Out32(TITLE_BASEADDR ,  (UINTPTR)LOAD_TEXT);
	status = XAxiDma_SimpleTransfer(&myDma, (u32)TxBuffer, 55*sizeof(u16),XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS){
		xil_printf("Greska u slanju transakcije\r\n");
	}

	while(!end_command_done);
	end_command_done = 0;

	do{
		start_tmp = IMAGE_1_ROW * part_of_photo;
		start_tmp = (start_tmp > 360) ? 360 : start_tmp;

		//LOAD PHOTO
		end_command_done = 0;
		load_photo_in_tx_buffer(input_image, TxBuffer, (360 - start_tmp) * 640 * 3, IMAGE_1_ROW * IMAGE_1_WIDTH * 3);
		Xil_Out32(TITLE_BASEADDR ,  (UINTPTR)LOAD_PHOTO);
		status = XAxiDma_SimpleTransfer(&myDma, (u32)TxBuffer, IMAGE_1_ROW * IMAGE_1_WIDTH * 3 *sizeof(u16), XAXIDMA_DMA_TO_DEVICE);
		if(status != XST_SUCCESS){
			xil_printf("Greska u slanju transakcije\r\n");
		}

		while(!end_command_done);
		end_command_done = 0;
		frame_finished_done = 0;

		//SEND POSSITIONY
		Xil_Out32(TITLE_BASEADDR + AXI_OFFSET , (u32)start_tmp);

		//START PROCESSING
		Xil_Out32(TITLE_BASEADDR ,  (UINTPTR)PROCESSING);
		while(!end_command_done && !frame_finished_done);
		end_command_done = 0;
		xil_printf("Zavrsena obrada %d. dela slike!\r\n", part_of_photo);

		//LOAD DATA FROM BRAM
		Xil_Out32(TITLE_BASEADDR ,  (UINTPTR)SEND_FROM_BRAM);
		status = XAxiDma_SimpleTransfer(&myDma, (u32)RxBuffer, IMAGE_1_ROW * IMAGE_1_WIDTH * 3 *sizeof(u16),XAXIDMA_DEVICE_TO_DMA);
		while ((XAxiDma_Busy(&myDma,XAXIDMA_DEVICE_TO_DMA)) && !end_command_done);
		end_command_done=0;

		for(int i = 0; i < IMAGE_1_ROW * IMAGE_1_WIDTH * 3; i++)
		{
			if(gv_image[(360 - start_tmp) * 640 * 3 + i] != (int)RxBuffer[i])
				miss++;
		}

		xil_printf("Broj promasaja za %d. dio slike:%d \r\n", part_of_photo, miss);

		part_of_photo++;

	}while(!frame_finished_done);

	Disable_Interrupt_System();
	cleanup_platform();

    return 0;
}


static void End_Command_Interrupt_Handler(void *Callback)
{
	end_command_done = 1;
}

static void Frame_Finished_Interrupt_Handler(void *Callback)
{
	frame_finished_done = 1;
}

u32 Setup_Interrupt(u32 DeviceId, Xil_InterruptHandler Handler, u32 interrupt_ID)
{
  //XScuGic_Config *IntcConfig;
  //XScuGic INTCInst;
  int status;
  // Extracts informations about processor core based on its ID, and they are used to setup interrupts
  IntcConfig = XScuGic_LookupConfig(DeviceId);

  // Initializes processor registers using information extracted in the previous step
  status = XScuGic_CfgInitialize(&INTCInst, IntcConfig, IntcConfig->CpuBaseAddress);
  if(status != XST_SUCCESS) return XST_FAILURE;
  status = XScuGic_SelfTest(&INTCInst);
  if (status != XST_SUCCESS) return XST_FAILURE;

  // Connect Timer Handler And Enable Interrupt
  // The processor can have multiple interrupt sources, and we must setup trigger and   priority
  // for the our interrupt. For this we are using interrupt ID.
   XScuGic_SetPriorityTriggerType(&INTCInst, interrupt_ID, 0xA8, 3);

  // Connects out interrupt with the appropriate ISR (Handler)
  status = XScuGic_Connect(&INTCInst, interrupt_ID, Handler, (void *)&INTCInst);
  if(status != XST_SUCCESS) return XST_FAILURE;

  // Enable interrupt for out device
  XScuGic_Enable(&INTCInst, interrupt_ID);

  //Two lines bellow enable exeptions
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			       (Xil_ExceptionHandler)XScuGic_InterruptHandler,&INTCInst);
  Xil_ExceptionEnable();

  return XST_SUCCESS;
}

void DMA_init_interrupts()
{
  u32 MM2S_DMACR_reg;
  u32 S2MM_DMACR_reg;

  Xil_Out32(DMA_BASEADDR + MM2S_DMACR_OFFSET,  DMACR_RESET); // writing to MM2S_DMACR register
  Xil_Out32(DMA_BASEADDR + S2MM_DMACR_OFFSET,  DMACR_RESET); // writing to S2MM_DMACR register

  /* THIS HERE IS NEEDED TO CONFIGURE DMA*/
  //enable interrupts
  MM2S_DMACR_reg = Xil_In32(DMA_BASEADDR + MM2S_DMACR_OFFSET); // Reading from MM2S_DMACR register inside DMA
  Xil_Out32((DMA_BASEADDR + MM2S_DMACR_OFFSET),  (MM2S_DMACR_reg | DMACR_IOC_IRQ_EN | DMACR_ERR_IRQ_EN)); // writing to MM2S_DMACR register
  S2MM_DMACR_reg = Xil_In32(DMA_BASEADDR + S2MM_DMACR_OFFSET); // Reading from S2MM_DMACR register inside DMA
  Xil_Out32((DMA_BASEADDR + S2MM_DMACR_OFFSET),  (S2MM_DMACR_reg | DMACR_IOC_IRQ_EN | DMACR_ERR_IRQ_EN)); // writing to S2MM_DMACR register
}

static void Disable_Interrupt_System()
{
  XScuGic_Disconnect(&INTCInst, INTERUPT_END_COMMAND_ID);
  XScuGic_Disconnect(&INTCInst, INTERUPT_FRAME_FINISHED_ID);
}

void load_int_in_tx_buffer(int* int_array, u16* u16_array, int num_of_parametars)
{
	for(int i=0; i<num_of_parametars; i++)
	{
		u16_array[i] = (u16)int_array[i];
	}
}

void load_photo_in_tx_buffer(int* photo, u16* array, int start, int number)
{
	for(int i=0; i<number; i++)
	{
		array[i] = (u16)photo[start+i];
	}
}

