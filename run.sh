set -exo pipefail

while getopts d:t:n:b:l: flag
do
    case "${flag}" in
        d) DATA_PATH=${OPTARG};;
        t) MODEL_TYPE=${OPTARG};;
        n) MODEL_NAME=${OPTARG};;
        b) BACKBONE=${OPTARG};;
        l) LOSS=${OPTARG};;
    esac
done

MODEL=$MODEL_TYPE/$MODEL_NAME

# train model
python3 train_model.py --data_path $DATA_PATH --model_type $MODEL_TYPE --model_name $MODEL_NAME --backbone $BACKBONE --loss $LOSS --epochs 60 --batch_size 1

mkdir -p -m=776 Evaluation_logs/$MODEL_TYPE

#Evaluate model and save results in eval/MODEL_NAME.txt file
python3 evaluate_model.py --data_path $DATA_PATH --model_type $MODEL_TYPE --model_name $MODEL_NAME --backbone $BACKBONE --loss $LOSS >> Evaluation_logs/$MODEL_TYPE/$MODEL_NAME.txt

# make predictions with the validation set and convert them to rgb
python3 create_predictions.py --data_path $DATA_PATH --model_type $MODEL_TYPE --model_name $MODEL_NAME --backbone $BACKBONE --split "val"
python3 convert2rgb.py --model_type $MODEL_TYPE --model_name $MODEL_NAME --split "val"

# make predictions with the test set and convert them to rgb
python3 create_predictions.py --data_path $DATA_PATH --model_type $MODEL_TYPE --model_name $MODEL_NAME --backbone $BACKBONE --split "test"
python3 convert2rgb.py --model_type $MODEL_TYPE --model_name $MODEL_NAME --split "test"

# zip the generated images and place the compressed file into the archives folder
zip -r archives/$MODEL_TYPE-$MODEL_NAME.zip predictions/$MODEL Evaluation_logs/$MODEL.txt Confusion_matrix/$MODEL.png