while getopts d:t:n:p: flag
do
    case "${flag}" in
        d) DATA_PATH=${OPTARG};;
        t) MODEL_TYPE=${OPTARG};;
        n) MODEL_NAME=${OPTARG};;
        p) PREPROCESSING=${OPTARG};;
    esac
done

MODEL=$MODEL_TYPE/$MODEL_NAME

## train model
python3 $MODEL_TYPE.py --data_path $DATA_PATH --model_type $MODEL_TYPE --model_name $MODEL_NAME --preprocessing $PREPROCESSING

mkdir -m=776 Evaluation_logs/$MODEL_TYPE
# Evaluate model and save results in eval/MODEL_NAME.txt file
python3 evaluate_model.py --data_path $DATA_PATH --model_type $MODEL_TYPE --model_name $MODEL_NAME --preprocessing $PREPROCESSING >> Evaluation_logs/$MODEL.txt

# make predictions with the validation set and convert them to rgb
python3 create_predictions.py --data_path $DATA_PATH --model_type $MODEL_TYPE --model_name $MODEL_NAME --preprocessing $PREPROCESSING --split "val"
python3 convert2rgb.py --model_type $MODEL_TYPE --model_name $MODEL_NAME --split "val"

# make predictions with the test set and convert them to rgb
python3 create_predictions.py --data_path $DATA_PATH --model_type $MODEL_TYPE --model_name $MODEL_NAME --preprocessing $PREPROCESSING --split "test"
python3 convert2rgb.py --model_type $MODEL_TYPE --model_name $MODEL_NAME --split "test"

# zip the generated images and place the compressed file into the archives folder
zip -r archives/$MODEL_TYPE-$MODEL_NAME.zip predictions/$MODEL Evaluation_logs/$MODEL.txt Confusion_matrix/$MODEL.png