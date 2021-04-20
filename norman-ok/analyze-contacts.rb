require 'csv'
require 'pp'

off_race = {}
cit_race = {}
race_differs = {}

ARGV.each do |file|
    puts file
    table = CSV.parse(File.read(file), headers: true)
    table.each { |r|
        next if !r['SubjectRole'].nil? && r['SubjectRole'] != 'Suspect'
        next if !r['TicketType'].nil? && r['TicketType'] == "Parking"

        next if !r['TicketType'].nil? && r['TicketType'] == "Warning"

        date = r['ReportedDate'] || r['ArrestDatetime'] || r['TicketDatetime'] || r['Occurred Date'] || r['Occurred date']
        year = date.split('/').last
        if year.length > 4
            year = '20' + date.split('-').last
        end
        off_race[year] ||= {}
        cit_race[year] ||= {}

        orace = r['OfficerRace']
        if !orace.nil?
            off_race[year][orace] ||= 0
            off_race[year][orace] += 1
        end

        crace = r['SubjectRace'] || r['Race']
        cit_race[year][crace] ||= 0
        cit_race[year][crace] += 1
    }
end

cit_race.each do |year, data|
    white = 0
    black = 0
    nonwhite = 0
    total = 0
    data.each do |race, count|
        next if race == "Unknown"
        total += count
        if race == "White"
            white += count
        elsif race == "Black"
            black += count
            nonwhite += count
        else
            nonwhite += count
        end
    end
    white_percent = white / total.to_f * 100
    black_percent = black / total.to_f * 100
    nonwhite_percent = nonwhite / total.to_f * 100
    puts "%s white %.2f%%, black %.2f%%, non-white %.2f%%, total %d" % [
        year, white_percent, black_percent, nonwhite_percent, total
    ]
end

