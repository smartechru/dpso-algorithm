function [info, names] = parse_data(raw_t, raw_s, raw_d)
    %% According the topic, classify the data
    % first row is the name of each column so ignore them
    [rows, ~] = size(raw_t);
    
    % initialize indice
    idx = 0;
    sub_id = 0;
    
    for i = 2: rows
        cur_topic = raw_t(i);
        cur_student = raw_s(i);
        cur_date = raw_d(i);
        
        %% Extract topic
        if cur_topic == ""
            sub_id = sub_id + 1;
        else
            idx = idx + 1;
            info(idx).topic = cur_topic;
            sub_id = 1;
        end
        
        %% Separate name and his choice
        % if 1st choice
        if contains(cur_student, "1st")
            k = strfind(cur_student, "1st");
            cur_student = convertStringsToChars(cur_student);

            info(idx).name(sub_id) = convertCharsToStrings(cur_student(1: k - 2));
            info(idx).choice(sub_id) = 1;
            info(idx).date(sub_id) = cur_date;
        
        % if 2nd choice
        elseif contains(cur_student, "2nd")
            k = strfind(cur_student, "2nd");
            cur_student = convertStringsToChars(cur_student);

            info(idx).name(sub_id) = convertCharsToStrings(cur_student(1: k - 2));
            info(idx).choice(sub_id) = 2;
            info(idx).date(sub_id) = cur_date;
        
        % if 3rd choice
        elseif contains(cur_student, "3rd")
            k = strfind(cur_student, "3rd");
            cur_student = convertStringsToChars(cur_student);

            info(idx).name(sub_id) = convertCharsToStrings(cur_student(1: k - 2));
            info(idx).choice(sub_id) = 3;
            info(idx).date(sub_id) = cur_date;
        end
        
    end
    
    %% Get name list and set the order for date/time
    names = "";
    name_id = 0;
    for i = 1: idx
        if ~isempty(info(i).name)
            % sort date/time
            sort_date = sort(info(i).date);
            
            for k = 1: length(info(i).name)
                if ~isequal(info(i).name(k), "")
                    % build name list
                    TF = contains(names, info(i).name(k));
                    if max(TF) == 0
                        name_id = name_id + 1;
                        names(name_id) = info(i).name(k);
                    end
                    
                    % build date/time list as integer
                    date_id = find(sort_date == info(i).date(k));
                    info(i).order(k) = date_id;
                end
            end
        end
    end
end